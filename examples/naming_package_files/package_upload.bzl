# Copyright 2021 The Bazel Authors. All rights reserved.
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
"""Example of how we can use PackageArtifactInfo to find an output name."""

load("@rules_pkg//pkg:providers.bzl", "PackageArtifactInfo")

def _debian_upload_impl(ctx):
    # Find out the basename of the deb file we created.
    pai = ctx.attr.package[PackageArtifactInfo]
    package_basename = pai.file_name.split(".")[0]
    content = ["# Uploading %s" % package_basename]
    for f in ctx.attr.package[DefaultInfo].default_runfiles.files.to_list():
        if f.basename.startswith(package_basename):
            content.append("gsutil cp %s gs://%s/%s" % (
                f.path,
                ctx.attr.host,
                f.basename,
            ))
    ctx.actions.write(ctx.outputs.out, "\n".join(content))

debian_upload = rule(
    implementation = _debian_upload_impl,
    doc = """A demonstraion of consuming PackageArtifactInfo to get a file name.""",
    attrs = {
        "package": attr.label(
            doc = "Package to upload",
            mandatory = True,
            providers = [PackageArtifactInfo],
        ),
        "host": attr.string(
            doc = "Host to upload to",
            mandatory = True,
        ),
        "out": attr.output(
            doc = "Script file to create.",
            mandatory = True,
        ),
    },
)
