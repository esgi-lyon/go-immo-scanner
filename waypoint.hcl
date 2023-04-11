# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

project = "go-immo-scanner"

variable "namespace" {
  default     = "default"
  type        = string
  description = "The namespace to deploy and release to in your Kubernetes cluster."
}

variable "registery_user" {
  type    = string
  description = "Username to login to container registry"
}

variable "registery_token" {
  type    = string
  description = "Token to login to container registry"
}

variable "k8s_ingress_annotations" {
  type    = map(string)
  description = "Kubernetes annotation to make ingress working"
  default  = {
    "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    "kubernetes.io/ingress.class" = "nginx"
  }
}

variable "k8s_ingress_domain" {
  type    = string
  description = "Kubernetes domain to use"
  default  = "waypoint.k3s.test"
}

app "go-multiapp-one" {
  labels = {
    "service" = "go-multiapp-one",
    "env"     = "dev"
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
        username = var.registery_user
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
        host = "go-multiapp.${var.k8s_ingress_domain}"
        annotations = var.k8s_ingress_annotations
        tls {
            hosts = ["go-multiapp.${var.k8s_ingress_domain}"]
            secret_name = "go-multiapp.${var.k8s_ingress_domain}-tls"
        }
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
        username = var.registery_user
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
        host = "go-multiapp.${var.k8s_ingress_domain}"
        annotations = var.k8s_ingress_annotations
        tls {
            hosts = ["go-multiapp.${var.k8s_ingress_domain}"]
            secret_name = "go-multiapp.${var.k8s_ingress_domain}-tls"
        }
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
        username = var.registery_user
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
        host = "go-multiapp.${var.k8s_ingress_domain}"
        annotations = var.k8s_ingress_annotations
        tls {
            hosts = ["go-multiapp.${var.k8s_ingress_domain}"]
            secret_name = "go-multiapp.${var.k8s_ingress_domain}-tls"
        }
      }
    }
  }
}
