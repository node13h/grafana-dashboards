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
