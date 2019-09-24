/**
 * Created by Eric Stansbury on 4/29/2019.
 */
({
    formatXml: function(xml, tab) { // tab = optional indent value, default is tab (\t)
        var formatted = '', indent= '';
        tab = tab || '    ';
        xml.split(/>\s*</).forEach(function(node) {
            if (node.match( /^\/\w/ )) indent = indent.substring(tab.length); // decrease indent by one 'tab'
            formatted += indent + '<' + node + '>\r\n';
            if (node.match( /^<?\w[^>]*[^\/]$/ )) indent += tab;              // increase indent
        });
        return formatted.substring(1, formatted.length-3);
    }
})