
function isEmpty(str) {
    return !str || str.length === 0;
}

function isBlank(str) {
    return !str || /^\s*$/.test(str);
}

String.prototype.isEmpty = function() {
    return this.length === 0;
};

String.prototype.isBlank = function() {
    return /^\s*$/.test(this);
};
