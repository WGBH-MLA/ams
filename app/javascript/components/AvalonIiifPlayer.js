import React from "react"
import PropTypes from "prop-types"
import IIIFPlayer from 'react-iiif-media-player'

const config = {
  fetch: {
    options: {
      credentials: 'include'
    }
  }
};

class AvalonIiifPlayer extends React.Component {
  render () {
    return (
      <div>
        <div id="iiif-manifest-url" data-manifest-url={this.props.manifestUrl}></div>
        <IIIFPlayer config={config} />
      </div>
    );
  }
}

AvalonIiifPlayer.propTypes = {
  manifestUrl: PropTypes.string,
  credentials: PropTypes.string
};
export default AvalonIiifPlayer
