group "default" {
  targets = ["image-release"]
}

variable "REPO" {
  default = "bubylou/moria"
}

variable "TAG" {
  default = "latest"
}

function "tags" {
  params = [suffix]
  result = ["ghcr.io/${REPO}:latest${suffix}", "ghcr.io/${REPO}:${TAG}${suffix}",
            "docker.io/${REPO}:latest${suffix}", "docker.io/${REPO}:${TAG}${suffix}"]
}

target "image-dev" {
  inherits = ["image-release"]
  cache-from = ["type=registry,ref=ghcr.io/bubylou/moria"]
  cache-to = ["type=inline"]
  args = {
    "STEAMCMD_VERSION" = "latest-wine"
  }
  env = {
    "UPDATE_ON_START" = "true"
    "RESET_SEED" = "true"
  }
}

target "image-release" {
  context = "."
  dockerfile = "Dockerfile"
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
  labels = {
    "org.opencontainers.image.source" = "https://github.com/bubylou/moria-docker"
    "org.opencontainers.image.authors" = "Nicholas Malcolm <bubylou@pm.me>"
    "org.opencontainers.image.licenses" = "MIT"
  }
  platforms = ["linux/amd64"]
  tags = tags("")
}

target "image-full" {
  inherits = ["image-release"]
  args = {
    "RELEASE" = "full"
  }
  tag = tags("-full")
}
