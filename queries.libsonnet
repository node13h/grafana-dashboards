local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local prometheusQuery = g.query.prometheus;

local variables = import './variables.libsonnet';

// TODO: move into "telegraf' parent key.

{
  cpuUsage(type, legend=null):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'cpu_usage_%s{job="telegraf", host="$%s", cpu="$%s"}' % [type, variables.host.name, variables.cpu.name]
    )
    + prometheusQuery.withRefId(type)
    + prometheusQuery.withLegendFormat(if legend != null then legend else type),

  diskUsage(type, legend=null):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'disk_%s{job="telegraf", host="$%s", path="$%s"}' % [type, variables.host.name, variables.mountpoint.name]
    )
    + prometheusQuery.withRefId(type)
    + prometheusQuery.withLegendFormat(if legend != null then legend else type),

  diskQueueDepth(id):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'rate(diskio_weighted_io_time{job="telegraf", host="$%s"}[$__rate_interval]) / 1000' % [variables.host.name]
    )
    + prometheusQuery.withRefId(id)
    + prometheusQuery.withLegendFormat('{{name}}'),

  diskLatency(type):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'rate(diskio_%s_time{job="telegraf", host="$%s"}[$__rate_interval]) / rate(diskio_%ss{job="telegraf", host="$%s"}[$__rate_interval])' % [type, variables.host.name, type, variables.host.name]
    )
    + prometheusQuery.withRefId(type)
    + prometheusQuery.withLegendFormat('{{name}}'),

  hostMetric(metric, id, legend=null):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      '%s{job="telegraf", host="$%s"}' % [metric, variables.host.name]
    )
    + prometheusQuery.withRefId(id)
    + prometheusQuery.withLegendFormat(if legend != null then legend else id),

  hostRateMetric(metric, id, legend=null):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'rate(%s{job="telegraf", host="$%s"}[$__rate_interval])' % [metric, variables.host.name]
    )
    + prometheusQuery.withRefId(id)
    + prometheusQuery.withLegendFormat(if legend != null then legend else id),
}
