local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local prometheusQuery = g.query.prometheus;

local variables = import './variables.libsonnet';

// TODO: move into "telegraf' parent key.

{
  cpuUsage(type, legend=null, cpu='$%s' % variables.cpu.name):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'cpu_usage_%s{job="telegraf", host="$%s", cpu="%s"}' % [type, variables.host.name, cpu]
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
      'rate(diskio_weighted_io_time{job="telegraf", host="$%s", name=~"$%s"}[$__rate_interval]) / 1000' % [variables.host.name, variables.disk.name]
    )
    + prometheusQuery.withRefId(id)
    + prometheusQuery.withLegendFormat('{{name}}'),

  diskLatency(type):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'rate(diskio_%s_time{job="telegraf", host="$%s", name=~"$%s"}[$__rate_interval]) / rate(diskio_%ss{job="telegraf", host="$%s", name=~"$%s"}[$__rate_interval])' % [type, variables.host.name, variables.disk.name, type, variables.host.name, variables.disk.name]
    )
    + prometheusQuery.withRefId(type)
    + prometheusQuery.withLegendFormat('{{name}}'),

  diskIops(type):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'rate(diskio_%ss{job="telegraf", host="$%s", name=~"$%s"}[$__rate_interval])' % [type, variables.host.name, variables.disk.name]
    )
    + prometheusQuery.withRefId(type)
    + prometheusQuery.withLegendFormat('{{name}}'),

  diskThroughput(type):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'rate(diskio_%s_bytes{job="telegraf", host="$%s", name=~"$%s"}[$__rate_interval])' % [type, variables.host.name, variables.disk.name]
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

  networkRateMetric(metric):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'rate(net_%s{job="telegraf", host="$%s", interface=~"$%s"}[$__rate_interval])' % [metric, variables.host.name, variables.interface.name]
    )
    + prometheusQuery.withRefId(metric)
    + prometheusQuery.withLegendFormat('{{interface}}'),

  uptime(id):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'system_uptime{job="telegraf", host="$%s"}' % [variables.host.name]
    )
    + prometheusQuery.withRefId(id),

  diskUsagePercentInstant(id):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      // Keep value and the path label only,
      'max by (path) (disk_used_percent{job="telegraf", host="$%s", path=~"$%s"})' % [variables.host.name, variables.mountpoint.name]
    )
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withFormat('table')
    + prometheusQuery.withRefId(id),

  mdAllArraysActive(id):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        count(mdstat_DisksTotal{job="telegraf", host="$%(hostvar)s", ActivityState=~"active|checking"}) OR vector(0)
        / count(mdstat_DisksTotal{job="telegraf", host="$%(hostvar)s"})
      ||| % { hostvar: variables.hostWithMdArrays.name }
    )
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withRefId(id),

  mdAllArrayMembersActive(id):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        sum without (Name, ActivityState) (mdstat_DisksActive{job="telegraf", host="$%(hostvar)s"})
        / sum without (Name, ActivityState) (mdstat_DisksTotal{job="telegraf", host="$%(hostvar)s"})
      ||| % { hostvar: variables.hostWithMdArrays.name }
    )
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withRefId(id),

  mdTotalArrays(id):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      |||
        count(mdstat_DisksTotal{job="telegraf", host="$%(hostvar)s"})
      ||| % { hostvar: variables.hostWithMdArrays.name }
    )
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withRefId(id)
    + prometheusQuery.withLegendFormat('total arrays'),

  mdMetric(metric, id, legend=null):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'mdstat_%s{job="telegraf", Name=~"$%s", host="$%s"}' % [metric, variables.mdArray.name, variables.hostWithMdArrays.name]
    )
    + prometheusQuery.withRefId(id)
    + prometheusQuery.withLegendFormat(if legend != null then legend else id),

  mdStatelessMetric(metric, id, legend=null):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'max(mdstat_%s{job="telegraf", Name=~"$%s", host="$%s"}) without (ActivityState)' % [metric, variables.mdArray.name, variables.hostWithMdArrays.name]
    )
    + prometheusQuery.withRefId(id)
    + prometheusQuery.withLegendFormat(if legend != null then legend else id),

  mdArrayState(id):
    self.mdMetric('DisksTotal', id, '{{ActivityState}}')
    + prometheusQuery.withInstant(true),

  mdActiveArrayMembers(id, legend=null):
    self.mdMetric('DisksActive', id, legend)
    + prometheusQuery.withInstant(true),

  mdTotalArrayMembers(id, legend=null):
    self.mdMetric('DisksTotal', id, legend)
    + prometheusQuery.withInstant(true),

  mdFailedArrayMembers(id):
    self.mdMetric('DisksFailed', id)
    + prometheusQuery.withInstant(true),

  mdSyncFinishTime(id):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'mdstat_BlocksSyncedFinishTime{job="telegraf", Name=~"$%s", host="$%s", ActivityState!="active"}' % [variables.mdArray.name, variables.hostWithMdArrays.name]
    )
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withRefId(id),

  mdSyncSpeed(id):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'mdstat_BlocksSyncedSpeed{job="telegraf", Name=~"$%s", host="$%s", ActivityState!="active"}' % [variables.mdArray.name, variables.hostWithMdArrays.name]
    )
    + prometheusQuery.withRefId(id),

  mdBlockSyncedPercentage(id):
    prometheusQuery.new(
      '$' + variables.datasource.name,
      'mdstat_BlocksSyncedPct{job="telegraf", Name=~"$%s", host="$%s"} > 0' % [variables.mdArray.name, variables.hostWithMdArrays.name]
    )
    + prometheusQuery.withInstant(true)
    + prometheusQuery.withRefId(id),
}
