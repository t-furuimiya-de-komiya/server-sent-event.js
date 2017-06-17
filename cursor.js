const FIELD_RE = /^([^\r\n:]*):? ?(.*)$/


module.exports = class ServerSentEventCursor
{
    constructor()
    {
        this.event = 'message'
        this.id = null
        this.retry = 1000
        this.data = []
    }

    fire()
    {
        const {event, id, data} = this
        this.event = 'message'
        this.data = []
        if (data.length)
            return {event, id, data, type: 'data', value: data}
    }

    proceed(line)
    {
        if (line.length === 0)
            return this.fire()

        const [_, key, val] = line.match(FIELD_RE)
        switch (key) {
            case 'id':
                this.id = val
                break
            case 'event':
                this.event = val
                break
            case 'data':
                this.data.push(val)
                break
            case 'retry':
                const x = parseInt(val, 10)
                if (0 < x)
                    this.retry = x
                else
                    return command('warning', `invalid retry value: ${val}`)
                break
            case '':
                return command('comment', val)
            default:
                return command('warning', `unknown field ${key}: ${val}`)
        }
    }
}

function command(type, value)
{
    return {type, value, [type]: value}
}
