data "template_file" "traefik" {
  template = "${file("${path.module}/traefik.yaml.tmpl")}"

  vars {
    jaeger_agent_endpoint = "${var.jaeger_agent_endpoint}"
    prometheus_enabled    = "${var.prometheus_enabled}"
    tracing_enabled       = "${var.tracing_enabled}"
    ssl_enabled           = "${var.ssl_enabled}"
    ssl_enforced          = "${var.ssl_enforced}"
    ssl_cert_base64       = "${var.ssl_cert_base64}"
    ssl_key_base64        = "${var.ssl_key_base64}"
  }
}

resource "null_resource" "generate_traefik_config" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.traefik.rendered}' > ${path.module}/traefik.yaml"
  }

  depends_on = ["data.template_file.traefik"]
}

resource "helm_release" "traefik" {
  chart     = "stable/traefik"
  name      = "traefik"
  namespace = "kube-system"
  timeout   = "${var.helm_install_timeout}"

  values = [
    "${file("${path.module}/traefik.yaml")}",
  ]

  set {
    name  = "replicas"
    value = "${var.ingress_replica_count}"
  }

  set {
    name  = "tracing.backend"
    value = "jaeger"
  }

  set {
    name  = "tracing.enabled"
    value = "true"
  }

  set {
    name  = "tracing.jaeger.localAgentHostPort"
    value = "jaeger-agent.jaeger.svc.cluster.local:6831"
  }

  set {
    name  = "tracing.jaeger.samplingServerURL"
    value = "http://jaeger-agent.jaeger.svc.cluster.local:5778/sampling}"
  }

  depends_on = ["null_resource.generate_traefik_config", "data.template_file.traefik"]
}
