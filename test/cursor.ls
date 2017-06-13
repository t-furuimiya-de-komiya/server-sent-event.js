require! './test.ls': {expect}
require! '..': {Cursor}


suite \cursor

function expect-data-event cur, ev
    expect cur.proceed ''
    .to.eql {ev.data, ev.id, ev.event, type: \data, value: ev.data}


test 'empty data' ->
    cur = new Cursor
    expect cur.proceed ''
    .not.to.exist

test 'data' ->
    cur = new Cursor
    expect cur.proceed 'data: nanika'
    .not.to.exist
    expect-data-event cur, data: <[nanika]>, id: null, event: \message

    cur.proceed 'data:1'
    cur.proceed 'data:'
    cur.proceed 'data:   '
    expect-data-event cur, data: [\1 '' '  '], id: null, event: \message


test 'id' ->
    cur = new Cursor

    expect cur.proceed 'id: abc'
    .not.to.exist
    expect cur.id .to.equal \abc

    expect cur.proceed ''
    .not.to.exist

    cur.proceed 'data: 1'
    expect-data-event cur, id: \abc, data: <[1]>, event: \message

    cur.proceed 'id: def'
    cur.proceed 'data: 2'
    expect-data-event cur, id: \def, data: <[2]>, event: \message

    cur.proceed 'data: 3'
    expect-data-event cur, id: \def, data: <[3]>, event: \message


test 'event' ->
    cur = new Cursor

    expect cur.proceed 'event: abc'
    .not.to.exist

    cur.proceed 'data: 1'
    expect-data-event cur, event: \abc, data: <[1]>, id: null

    cur.proceed 'data: 2'
    expect-data-event cur, event: \message, data: <[2]>, id: null

    cur.proceed 'event: abc'
    cur.proceed 'event: def'
    cur.proceed 'data: 3'
    expect-data-event cur, event: \def, data: <[3]>, id: null


test 'retry' ->
    cur = new Cursor
    expect cur.proceed 'retry: 123456'
    .not.to.exist
    expect cur.retry .to.equal 123456
    expect cur.proceed 'retry: hoge'
    .to.eql {
        type: \warning
        value: 'invalid retry value: hoge'
        warning: 'invalid retry value: hoge'
    }
    expect cur.retry .to.equal 123456
    expect cur.proceed ''
    .not.to.exist


test 'comment' ->
    cur = new Cursor
    expect cur.proceed ':   this is a comment'
    .to.eql {
        type: \comment
        value: '  this is a comment'
        comment: '  this is a comment'
    }
    expect cur.proceed ''
    .not.to.exist


test 'unknown field warning' ->
    cur = new Cursor
    expect cur.proceed '   :   '
    .to.eql {
        type: \warning
        value: 'unknown field    :   '
        warning: 'unknown field    :   '
    }
    expect cur.proceed 'abcd efg'
    .to.eql {
        type: \warning
        value: 'unknown field abcd efg: '
        warning: 'unknown field abcd efg: '
    }
    expect cur.proceed ''
    .not.to.exist
