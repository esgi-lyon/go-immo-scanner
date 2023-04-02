# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

project = "kubernetes-go-multiapp-k8s-ingress"

variable "namespace" {
  default     = "default"
  type        = string
  description = "The namespace to deploy and release to in your Kubernetes cluster."
}

variable "registery_token" {
  type    = string
  description = "Token to login to github container registry"
}

app "go-multiapp-one" {
  labels = {
    "service" = "go-multiapp-one",
    "env"     = "dev"
    "org.opencontainers.image.source" = "https://github.com/loic-roux-404/go-immo-scanner"
  }

  config {
    env = {
      WP_NODE = "ONE"
    }
  }

  build {
    use "pack" {}
    registry {
      use "docker" {
        image = "loicroux/go-multiapp-one"
        tag   = "1"
        local = false
        password = var.registery_token
        username = "loicroux"
      }
    }
  }

  deploy {
    use "kubernetes" {
      probe_path = "/"
      namespace  = var.namespace
    }
  }

  release {
    use "kubernetes" {
      namespace = var.namespace

      ingress "http" {
        path_type = "Prefix"
        path      = "/app-one"
      }
    }
  }

}


app "go-multiapp-two" {
  labels = {
    "service" = "go-multiapp-two",
    "env"     = "dev"
  }

  config {
    env = {
      WP_NODE = "TWO"
    }
  }

  build {
    use "pack" {}
    registry {
      use "docker" {
        image = "loicroux/go-multiapp-two"
        tag   = "1"
        local = false
        password = var.registery_token
        username = "loicroux"
      }
    }
  }

  deploy {
    use "kubernetes" {
      probe_path = "/"
      namespace  = var.namespace
    }
  }

  release {
    use "kubernetes" {
      namespace = var.namespace

      ingress "http" {
        path_type = "Prefix"
        path      = "/app-two"
      }
    }
  }
}

app "default-app" {
  labels = {
    "service" = "default-app",
    "env"     = "dev"
  }

  build {
    use "pack" {}
    registry {
      use "docker" {
        image = "loicroux/default-app"
        tag   = "1"
        local = false
        password = var.registery_token
        username = "loicroux"
      }
    }
  }

  deploy {
    use "kubernetes" {
      probe_path = "/"
      namespace  = var.namespace
    }
  }

  release {
    use "kubernetes" {
      namespace = var.namespace

      ingress "http" {
        default   = true
        path_type = "Prefix"
        path      = "/"
      }
    }
  }
}
