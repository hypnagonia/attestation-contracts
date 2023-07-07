const fs = require('fs');


const dbPath = `../tmp/contracts/var.json`

const save = (variable) => {


    let db = {}

    try {
        db = load()
    } catch (e) { }

    fs.writeFileSync(
        dbPath,
        JSON.stringify({ ...db, ...variable }),
        { flag: 'w' }
    );
}

const load = () => {
    try {
        const res = fs.readFileSync(
            dbPath,
            'utf8'
        );

        return JSON.parse(res)
    } catch (e) {
    }

    return {}
}

module.exports = {
    save,
    load
}