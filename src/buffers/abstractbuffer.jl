abstract type AbstractBuffer end

function isfull end
function capacity end

## methods below from Base also need to be extended
function push! end
function getindex end
function view end
function length end
function empty! end
function lastindex end