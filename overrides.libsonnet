local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
  timeSeries: {
    local timeSeries = g.panel.timeSeries,

    colored(refId, color):
      timeSeries.standardOptions.override.byQuery.new(refId)
      + timeSeries.standardOptions.override.byType.withPropertiesFromOptions(
        timeSeries.standardOptions.color.withFixedColor(color)
        + timeSeries.standardOptions.color.withMode('fixed')
      ),

    availableResource(refId):
      timeSeries.standardOptions.override.byQuery.new(refId)
      + timeSeries.standardOptions.override.byType.withPropertiesFromOptions(
        timeSeries.standardOptions.color.withFixedColor('light-green')
        + timeSeries.standardOptions.color.withMode('fixed')
        + timeSeries.fieldConfig.defaults.custom.withFillOpacity(20)
        + timeSeries.fieldConfig.defaults.custom.withLineWidth(0)
      ),

    capacityLine(refId):
      timeSeries.standardOptions.override.byQuery.new(refId)
      + timeSeries.standardOptions.override.byType.withPropertiesFromOptions(
        timeSeries.standardOptions.color.withFixedColor('gray')
        + timeSeries.standardOptions.color.withMode('fixed')
        + timeSeries.fieldConfig.defaults.custom.withDrawStyle('line')
        + timeSeries.fieldConfig.defaults.custom.lineStyle.withDash([5, 10])
        + timeSeries.fieldConfig.defaults.custom.lineStyle.withFill('dash')
      ),
  },

  table: {
    local table = g.panel.table,

    gauge(fieldName):
      table.standardOptions.override.byName.new(fieldName)
      + table.standardOptions.override.byName.withPropertiesFromOptions(
        table.fieldConfig.defaults.custom.cellOptions.TableBarGaugeCellOptions.withMode('basic')
        + table.fieldConfig.defaults.custom.cellOptions.TableBarGaugeCellOptions.withType('gauge')
      ),
  },
}
