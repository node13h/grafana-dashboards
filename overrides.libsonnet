local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

{
  timeSeries: {
    local timeSeries = g.panel.timeSeries,

    colored(refId, color):
      timeSeries.standardOptions.override.byQuery.new(refId)
      + timeSeries.standardOptions.override.byQuery.withProperty(
        'color', { fixedColor: color, mode: 'fixed' }
      ),

    availableResource(refId):
      timeSeries.standardOptions.override.byQuery.new(refId)
      + timeSeries.standardOptions.override.byQuery.withProperty(
        'color', { fixedColor: 'light-green', mode: 'fixed' }
      )
      + timeSeries.standardOptions.override.byQuery.withProperty(
        'custom.fillOpacity', 20
      )
      + timeSeries.standardOptions.override.byQuery.withProperty(
        'custom.lineWidth', 0
      ),

    capacityLine(refId):
      timeSeries.standardOptions.override.byQuery.new(refId)
      + timeSeries.standardOptions.override.byQuery.withProperty(
        'color', { fixedColor: 'gray', mode: 'fixed' }
      )
      + timeSeries.standardOptions.override.byQuery.withProperty(
        'custom.lineStyle', { dash: [0, 10], fill: 'dot' }
      )
      + timeSeries.standardOptions.override.byQuery.withProperty(
        'custom.drawStyle', 'line'
      ),
  },
}
