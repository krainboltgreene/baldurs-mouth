import cytoscape from 'cytoscape';

export default {
  mounted() {
    this.handleEvent('draw', this.draw.bind(this));
    this.pushEvent('build-graph', {});
  },
  draw(data) {
    return cytoscape({
      container: this.el, // container to render in
        // panningEnabled: false,
        // zoomingEnabled: false,
      boxSelectionEnabled: false,
      elements: data.elements,
      layout: {
        name: 'breadthfirst',
        nodeDimensionsIncludeLabels: true,
      },
      style: [ // the stylesheet for the graph
        {
          selector: 'node[type="dialogue"]',
          style: {
            'background-color': 'blue'
          }
        },
        {
          selector: 'node[type="scene"]',
          style: {
            'background-color': 'red',
            'label': 'data(name)'
          }
        },

        {
          selector: 'edge',
          style: {
            'width': 2,
            'line-color': '#ccc',
            'target-arrow-color': '#ccc',
            'target-arrow-shape': 'triangle',
            'curve-style': 'bezier'
          }
        }
      ]
    });
  }
}
