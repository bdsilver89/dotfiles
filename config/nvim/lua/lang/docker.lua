return {
  parsers = { "dockerfile" },

  servers = {
    dockerls = {},
    docker_compose_language_service = {},
  },

  mason = { "dockerls", "docker_compose_language_service", "hadolint" },

  linters_by_ft = {
    dockerfile = { "hadolint" },
  },
}
