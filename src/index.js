const Cursor = require('./cursor')
const Stream = require('./stream')

module.exports = serverSentEvent
serverSentEvent.Cursor = Cursor
serverSentEvent.Stream = Stream

function serverSentEvent(split, cursor)
{
    cursor = cursor || new Cursor
    return function* scanner(buf) {
        for (let line of split(buf)) {
            const info = cursor.proceed(line)
            scanner.retry = cursor.retry
            scanner.id = cursor.id
            if (info)
                yield info
        }
    }
}
