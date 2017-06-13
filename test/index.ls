require! './test.ls': {expect}
require! '..': server-sent-event
require! 'line-spliter': LineSpliter


function yielded-command type, value
    done: false
    value: {type, value, (type): value}


const CHUNK0 = '''

: comment 1
: comment 2

retry: 42

event: abc
id: xyz
: in between comment
data: hoge
data: fu
'''

const CHUNK1 = '''
ga

dat
'''

suite \scanner

test 'chunked input' ->
    spliter = new LineSpliter
    scanner = server-sent-event -> spliter.push it

    i = scanner CHUNK0

    expect i.next!
    .to.be.eql yielded-command \comment, 'comment 1'

    expect i.next!
    .to.be.eql yielded-command \comment, 'comment 2'

    expect i.next!
    .to.be.eql yielded-command \comment, 'in between comment'

    expect scanner.retry .to.be.equal 42

    expect i.next! .to.have.property \done, true


    i = scanner CHUNK1

    expect i.next! .to.be.eql done: false, value:
        event: \abc
        id: \xyz
        data: <[hoge fuga]>
        type: \data
        value: <[hoge fuga]>

    expect i.next! .to.have.property \done, true


    i = scanner '\n\n'
    expect i.next!
    .to.be.eql yielded-command \warning, 'unknown field dat: '
    expect i.next! .to.have.property \done, true
