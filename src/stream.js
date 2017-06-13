const {Transform} = require('stream')
const Cursor = require('./cursor')


module.exports = class ServerSentEventStream extends Transform
{
    constructor(opts)
    {
        this.opts = opts || {}
        super({objectMode: true})
        this.cursor = this.opts.cursor || new Cursor
    }

    get state()
    {
        const {id, retry} = this.cursor
        return {id, retry}
    }

    _transform(line, enc, done)
    {
        try {
            if (line = this.cursor.proceed(line)) {
                const {data, comment, warning} = line
                if (comment)
                    this.emit('comment', comment)
                if (warning)
                    this.emit('warn', warning)
                if (data)
                    this.push(line)
            }
            done()
        } catch (err) {
            done(err)
        }
    }
}
