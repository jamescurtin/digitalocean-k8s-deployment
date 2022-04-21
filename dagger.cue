package main

import (
    "dagger.io/dagger"
    "dagger.io/dagger/core"
    "universe.dagger.io/bash"
    "universe.dagger.io/docker"
)

dagger.#Plan & {
    client: {
        filesystem: {
            ".": {
                read: {
                    contents: dagger.#FS
                    exclude: [
                        ".github",
                        "cue.mod",
                        "dagger.cue",
                        "LICENSE",
                        "README.md",
                    ]
                }
            }
            "./": write: contents: actions.fix.output
        }
    }

    actions: {
        _bin: core.#Source & {
            path: "./bin"
        }
        _build_lint: docker.#Build & {
            steps: [
                docker.#Pull & {
                    source: "debian:stable-slim"
                },
                bash.#Run & {
                    script: {
                        directory: _bin.output
                        filename: "setup-ci"
                    }
                },
                docker.#Copy & {
                    dest: "/io"
                    contents: client.filesystem.".".read.contents
                },
            ]
        }
        _lint_image: _build_lint.output

        _build_shellcheck: docker.#Build & {
            steps: [
                docker.#Pull & {
                    source: "koalaman/shellcheck-alpine"
                },
                docker.#Copy & {
                    dest: "/mnt"
                    contents: client.filesystem.".".read.contents
                },
            ]
        }
        _shellcheck_image: _build_shellcheck.output

        // Run linting suite
        lint: {
            terraform_fmt: docker.#Run & {
                input: _lint_image
                workdir: "/io"
                entrypoint: ["terraform"]
                command: {
                    name: "fmt"
                    args: ["--check", "--recursive"]
                }
            }
            helm_lint: bash.#Run & {
                input: _lint_image
                script: {
                    directory: _bin.output
                    filename: "helm-lint"
                }
            }
            shellcheck: docker.#Run & {
                input: _shellcheck_image
                workdir: "/mnt"
                entrypoint: ["/bin/sh"]
                command: {
                    name: "-c"
                    args: ["/bin/shellcheck bin/*"]
                }
            }
            shfmt: bash.#Run & {
                input: _lint_image
                workdir: "/io"
                script: {
                    contents: "/root/.go/bin/shfmt -f . | xargs /root/.go/bin/shfmt -s -d"
                }
            }
        }

        // Auto-resolve test and lint issues
        fix: {
            helm_lint: bash.#Run & {
                input: terraform_fmt.output
                script: {
                    directory: _bin.output
                    filename: "helm-lint"
                }
            }
            terraform_fmt: docker.#Run & {
                input: _lint_image
                workdir: "/io"
                export: directories: {
                    "/io": _
                }
                entrypoint: ["terraform"]
                command: {
                    name: "fmt"
                    args: ["--recursive"]
                }
            }
            shfmt: bash.#Run & {
                input: terraform_fmt.output
                workdir: "/io"
                export: directories: {
                    "/io": _
                }
                script: {
                    contents: "/root/.go/bin/shfmt -f . | xargs /root/.go/bin/shfmt -s -w"
                }
            }
            output: shfmt.export.directories."/io"
        }
    }
}
