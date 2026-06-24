.pragma library
.import NERvGear.Templates 1.0 as T

// Data

function list() {
    return this.values;
}

function query(name) {
    for (let i = 0; i < this.values.length; ++i) {
        const value = this.values[i];
        if (value instanceof T.Value) {
            if (value.name === name)
                return value;
        }
    }
    return null;
}

// Value

function execute() {
    return Promise.reject();
}
