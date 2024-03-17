# Grafana dashboards

Misc Grafana dashboards built using [Grafonnet](https://grafana.github.io/grafonnet/index.html).

## Telegraf / System dashboard

System metrics such as CPU, memory, disk, network collected by Telegraf into
Prometheus.

<details>
<summary>Example Telegraf input plugin config</summary>

```toml
[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false
  core_tags = false

[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]

[[inputs.diskio]]

[[inputs.kernel]]

[[inputs.mem]]

[[inputs.processes]]

[[inputs.swap]]

[[inputs.system]]

[[inputs.net]]
  interfaces = ["eth*", "enp*", "br*", "eno*"]
```

</details>

## GitLab CI variables

See [ci-variables.yaml](ci-variables.yaml).

## Developing

See [DEVELOPING.md](DEVELOPING.md) for local development setup instructions.
