local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local var = g.dashboard.variable;

{
  datasource:
    var.datasource.new('datasource', 'prometheus'),

  host:
    var.query.new('host')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'host',
      'cpu_usage_idle{job="telegraf"}',
    )
    + var.query.refresh.onTime(),

  hostWithMdArrays:
    var.query.new('host')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'host',
      'mdstat_DisksTotal{job="telegraf"}',
    )
    + var.query.refresh.onTime(),

  mdArray:
    var.query.new('array')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'Name',
      'mdstat_DisksTotal{job="telegraf", host="$%s"}' % self.hostWithMdArrays.name,
    )
    + var.query.refresh.onTime()
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(),

  cpu:
    var.query.new('cpu')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'cpu',
      'cpu_usage_idle{job="telegraf", host="$%s"}' % self.host.name,
    )
    + var.query.withRegex('/cpu[0-9]+/')
    + var.query.refresh.onTime()
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(),

  disk:
    var.query.new('disk')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'name',
      'diskio_reads{job="telegraf", host="$%s"}' % self.host.name,
    )
    + var.query.refresh.onTime()
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(),

  interface:
    var.query.new('interface')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'interface',
      'net_bytes_recv{job="telegraf", host="$%s"}' % self.host.name,
    )
    + var.query.refresh.onTime()
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(),

  mountpoint:
    var.query.new('mountpoint')
    + var.query.withDatasourceFromVariable(self.datasource)
    + var.query.queryTypes.withLabelValues(
      'path',
      'disk_total{job="telegraf", host="$%s"}' % self.host.name,
    )
    + var.query.refresh.onTime()
    + var.query.selectionOptions.withMulti(true)
    + var.query.selectionOptions.withIncludeAll(),

}
