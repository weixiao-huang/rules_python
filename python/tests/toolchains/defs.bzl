# Copyright 2022 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""This module contains the definition for the toolchains testing rules.
"""

def _acceptance_test_impl(ctx):
    workspace = ctx.actions.declare_file("/".join([ctx.attr.python_version, "WORKSPACE"]))
    ctx.actions.expand_template(
        template = ctx.file._workspace_tmpl,
        output = workspace,
        substitutions = {"%python_version%": ctx.attr.python_version},
    )

    build_bazel = ctx.actions.declare_file("/".join([ctx.attr.python_version, "BUILD.bazel"]))
    ctx.actions.expand_template(
        template = ctx.file._build_bazel_tmpl,
        output = build_bazel,
        substitutions = {"%python_version%": ctx.attr.python_version},
    )

    python_version_test = ctx.actions.declare_file("/".join([ctx.attr.python_version, "python_version_test.py"]))

    # With the current approach in the run_acceptance_test.sh, we use this
    # symlink to find the absolute path to the rules_python to be passed to the
    # --override_repository rules_python=<rules_python_path>.
    ctx.actions.symlink(
        target_file = ctx.file._python_version_test,
        output = python_version_test,
    )

    executable = ctx.actions.declare_file("run_acceptance_test_{}.sh".format(ctx.attr.python_version))
    ctx.actions.expand_template(
        template = ctx.file._run_acceptance_test,
        output = executable,
        substitutions = {
            "%python_version%": ctx.attr.python_version,
            "%test_location%": "/".join([ctx.attr.test_location, ctx.attr.python_version]),
        },
        is_executable = True,
    )

    files = [
        workspace,
        build_bazel,
        python_version_test,
    ]
    return [DefaultInfo(
        executable = executable,
        files = depset(files),
        runfiles = ctx.runfiles(files),
    )]

_acceptance_test = rule(
    _acceptance_test_impl,
    attrs = {
        "python_version": attr.string(
            mandatory = True,
        ),
        "test_location": attr.string(
            mandatory = True,
        ),
        "_build_bazel_tmpl": attr.label(
            allow_single_file = True,
            default = "//python/tests/toolchains/workspace_template:BUILD.bazel.tmpl",
        ),
        "_python_version_test": attr.label(
            allow_single_file = True,
            default = "//python/tests/toolchains/workspace_template:python_version_test.py",
        ),
        "_run_acceptance_test": attr.label(
            allow_single_file = True,
            default = "//python/tests/toolchains:run_acceptance_test.sh",
        ),
        "_workspace_tmpl": attr.label(
            allow_single_file = True,
            default = "//python/tests/toolchains/workspace_template:WORKSPACE.tmpl",
        ),
    },
    test = True,
)

def acceptance_test(python_version, **kwargs):
    _acceptance_test(
        python_version = python_version,
        test_location = native.package_name(),
        **kwargs
    )
