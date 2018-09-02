abstract type AbstractBuffer end

"Add data into buffer"
function push! end

"Check is the buffer full"
function isfull end

"Support access by index"
function getindex end

"Support view without copy"
function view end