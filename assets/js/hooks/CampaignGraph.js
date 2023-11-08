import cytoscape from 'cytoscape';

export default {
  mounted() {
    console.log('CampaignGraph mounted')
    this.handleEvent('draw', this.draw.bind(this));
    this.pushEvent('build-graph', {});
  },
  draw(data) {
    console.log(data);
    cytoscape({
      container: this.el, // container to render in
      panningEnabled: false,
      zoomingEnabled: false,
      boxSelectionEnabled: false,
      elements: [ // list of graph elements to start with
        { // node a
          data: { id: 'a' },
          grabble: true,
          selectable: true
        },
        { // node b
          data: { id: 'b' },
          grabble: true,
          selectable: true
        },
        { // edge ab
          data: { id: 'ab', source: 'a', target: 'b' },
          grabble: true,
          selectable: true
        }
      ],
      style: [ // the stylesheet for the graph
        {
          selector: 'node',
          style: {
            'background-color': '#666',
            'label': 'data(id)'
          }
        },

        {
          selector: 'edge',
          style: {
            'width': 3,
            'line-color': '#ccc',
            'target-arrow-color': '#ccc',
            'target-arrow-shape': 'triangle',
            'curve-style': 'bezier'
          }
        }
      ],

      layout: {
        name: 'grid',
        rows: 1
      }
    });
  }
}
