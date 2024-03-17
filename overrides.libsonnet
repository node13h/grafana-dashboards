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
        + timeSeries.fieldConfig.defaults.custom.lineStyle.withDash([0, 10])
        + timeSeries.fieldConfig.defaults.custom.lineStyle.withFill('dot')
      ),
  },
}
