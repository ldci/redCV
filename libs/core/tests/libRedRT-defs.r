[[
        make [action! 2 [type [datatype! word!] spec [any-type!]] #[none]] 
        random [action! 1 [{Returns a random value of the same datatype; or shuffles series} value "Maximum value of result (modified when series)" /seed "Restart or randomize" /secure "Returns a cryptographically secure random number" /only "Pick a random value from a series" return: [any-type!]] [/seed 1 0 /secure 2 0 /only 3 0]] 
        reflect [action! 2 [{Returns internal details about a value via reflection} value [any-type!] field [word!] {spec, body, words, etc. Each datatype defines its own reflectors}] #[none]] 
        to [action! 2 ["Converts to a specified datatype" type [any-type!] "The datatype or example value" spec [any-type!] "The attributes of the new value"] #[none]] 
        form [action! 1 [{Returns a user-friendly string representation of a value} value [any-type!] /part "Limit the length of the result" limit [integer!] return: [string!]] [/part 1 1]] 
        mold [action! 1 [{Returns a source format string representation of a value} value [any-type!] /only "Exclude outer brackets if value is a block" /all "TBD: Return value in loadable format" /flat "TBD: Exclude all indentation" /part "Limit the length of the result" limit [integer!] return: [string!]] [/only 1 0 /all 2 0 /flat 3 0 /part 4 1]] 
        modify [action! 3 ["Change mode for target aggregate value" target [object! series!] field [word!] value [any-type!] /case "Perform a case-sensitive lookup"] [/case 1 0]] 
        absolute [action! 1 ["Returns the non-negative value" value [number! money! char! pair! time!] return: [number! money! char! pair! time!]] #[none]] 
        add [action! 2 ["Returns the sum of the two values" value1 [scalar! vector!] "The augend" value2 [scalar! vector!] "The addend" return: [scalar! vector!] "The sum"] #[none]] 
        divide [action! 2 ["Returns the quotient of two values" value1 [number! money! char! pair! tuple! vector! time!] "The dividend (numerator)" value2 [number! money! char! pair! tuple! vector! time!] "The divisor (denominator)" return: [number! money! char! pair! tuple! vector! time!] "The quotient"] #[none]] 
        multiply [action! 2 ["Returns the product of two values" value1 [number! money! char! pair! tuple! vector! time!] "The multiplicand" value2 [number! money! char! pair! tuple! vector! time!] "The multiplier" return: [number! money! char! pair! tuple! vector! time!] "The product"] #[none]] 
        negate [action! 1 ["Returns the opposite (additive inverse) value" number [number! money! bitset! pair! time!] return: [number! money! bitset! pair! time!]] #[none]] 
        power [action! 2 [{Returns a number raised to a given power (exponent)} number [number!] "Base value" exponent [integer! float!] "The power (index) to raise the base value by" return: [number!]] #[none]] 
        remainder [action! 2 [{Returns what is left over when one value is divided by another} value1 [number! money! char! pair! tuple! vector! time!] "The dividend (numerator)" value2 [number! money! char! pair! tuple! vector! time!] "The divisor (denominator)" return: [number! money! char! pair! tuple! vector! time!] "The remainder"] #[none]] 
        round [action! 1 [{Returns the nearest integer. Halves round up (away from zero) by default} n [number! money! time! pair!] /to "Return the nearest multiple of the scale parameter" scale [number! money! time!] "Must be a non-zero value" /even "Halves round toward even results" /down {Round toward zero, ignoring discarded digits. (truncate)} /half-down "Halves round toward zero" /floor "Round in negative direction" /ceiling "Round in positive direction" /half-ceiling "Halves round in positive direction"] [/to 1 1 /even 2 0 /down 3 0 /half-down 4 0 /floor 5 0 /ceiling 6 0 /half-ceiling 7 0]] 
        subtract [action! 2 ["Returns the difference between two values" value1 [scalar! vector!] "The minuend" value2 [scalar! vector!] "The subtrahend" return: [scalar! vector!] "The difference"] #[none]] 
        even? [action! 1 [{Returns true if the number is evenly divisible by 2} number [number! money! char! time!] return: [logic!]] #[none]] 
        odd? [action! 1 [{Returns true if the number has a remainder of 1 when divided by 2} number [number! money! char! time!] return: [logic!]] #[none]] 
        and~ [action! 2 ["Returns the first value ANDed with the second" value1 [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!] value2 [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!] return: [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]] #[none]] 
        complement [action! 1 [{Returns the opposite (complementing) value of the input value} value [logic! integer! tuple! bitset! typeset! binary!] return: [logic! integer! tuple! bitset! typeset! binary!]] #[none]] 
        or~ [action! 2 ["Returns the first value ORed with the second" value1 [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!] value2 [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!] return: [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]] #[none]] 
        xor~ [action! 2 [{Returns the first value exclusive ORed with the second} value1 [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!] value2 [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!] return: [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]] #[none]] 
        append [action! 2 [{Inserts value(s) at series tail; returns series head} series [series! bitset! port!] value [any-type!] /part "Limit the number of values inserted" length [number! series!] /only {Insert block types as single values (overrides /part)} /dup "Duplicate the inserted values" count [integer!] return: [series! port! bitset!]] [/part 1 1 /only 2 0 /dup 3 1]] 
        at [action! 2 ["Returns a series at a given index" series [series! port!] index [integer! pair!] return: [series! port!]] #[none]] 
        back [action! 1 ["Returns a series at the previous index" series [series! port!] return: [series! port!]] #[none]] 
        change [action! 2 [{Changes a value in a series and returns the series after the change} series [series! port!] "Series at point to change" value [any-type!] "The new value" /part {Limits the amount to change to a given length or position} range [number! series!] /only "Changes a series as a series." /dup "Duplicates the change a specified number of times" count [number!]] [/part 1 1 /only 2 0 /dup 3 1]] 
        clear [action! 1 [{Removes series values from current index to tail; returns new tail} series [series! port! bitset! map! none!] return: [series! port! bitset! map! none!]] #[none]] 
        copy [action! 1 ["Returns a copy of a non-scalar value" value [series! any-object! bitset! map!] /part "Limit the length of the result" length [number! series! pair!] /deep "Copy nested values" /types "Copy only specific types of non-scalar values" kind [datatype!] return: [series! any-object! bitset! map!]] [/part 1 1 /deep 2 0 /types 3 1]] 
        find [action! 2 ["Returns the series where a value is found, or NONE" series [series! bitset! typeset! port! map! none!] value [any-type!] /part "Limit the length of the search" length [number! series!] /only "Treat a series search value as a single value" /case "Perform a case-sensitive search" /same {Use "same?" as comparator} /any "TBD: Use * and ? wildcards in string searches" /with "TBD: Use custom wildcards in place of * and ?" wild [string!] /skip "Treat the series as fixed size records" size [integer!] /last "Find the last occurrence of value, from the tail" /reverse {Find the last occurrence of value, from the current index} /tail {Return the tail of the match found, rather than the head} /match {Match at current index only and return tail of match}] [/part 1 1 /only 2 0 /case 3 0 /same 4 0 /any 5 0 /with 6 1 /skip 7 1 /last 8 0 /reverse 9 0 /tail 10 0 /match 11 0]] 
        head [action! 1 ["Returns a series at its first index" series [series! port!] return: [series! port!]] #[none]] 
        head? [action! 1 ["Returns true if a series is at its first index" series [series! port!] return: [logic!]] #[none]] 
        index? [action! 1 [{Returns the current index of series relative to the head, or of word in a context} series [series! port! any-word!] return: [integer!]] #[none]] 
        insert [action! 2 [{Inserts value(s) at series index; returns series past the insertion} series [series! port! bitset!] value [any-type!] /part "Limit the number of values inserted" length [number! series!] /only {Insert block types as single values (overrides /part)} /dup "Duplicate the inserted values" count [integer!] return: [series! port! bitset!]] [/part 1 1 /only 2 0 /dup 3 1]] 
        length? [action! 1 [{Returns the number of values in the series, from the current index to the tail} series [series! port! bitset! map! tuple! none!] return: [integer! none!]] #[none]] 
        move [action! 2 [{Moves one or more elements from one series to another position or series} origin [series! port!] target [series! port!] /part "Limit the number of values inserted" length [integer!] return: [series! port!]] [/part 1 1]] 
        next [action! 1 ["Returns a series at the next index" series [series! port!] return: [series! port!]] #[none]] 
        pick [action! 2 ["Returns the series value at a given index" series [series! port! bitset! pair! tuple! money! date! time!] index [scalar! any-string! any-word! block! logic! time!] return: [any-type!]] #[none]] 
        poke [action! 3 [{Replaces the series value at a given index, and returns the new value} series [series! port! bitset!] index [scalar! any-string! any-word! block! logic!] value [any-type!] return: [series! port! bitset!]] #[none]] 
        put [action! 3 [{Replaces the value following a key, and returns the new value} series [series! port! map! object!] key [scalar! any-string! any-word! binary!] value [any-type!] /case "Perform a case-sensitive search" return: [series! port! map! object!]] [/case 1 0]] 
        remove [action! 1 [{Returns the series at the same index after removing a value} series [series! port! bitset! map! none!] /part {Removes a number of values, or values up to the given series index} length [number! char! series!] /key "Removes a key in map" key-arg [scalar! any-string! any-word! binary! block!] return: [series! port! bitset! map! none!]] [/part 1 1 /key 2 1]] 
        reverse [action! 1 [{Reverses the order of elements; returns at same position} series [series! port! pair! tuple!] /part "Limits to a given length or position" length [number! series!] /skip "Treat the series as fixed size records" size [integer!] return: [series! port! pair! tuple!]] [/part 1 1 /skip 2 1]] 
        select [action! 2 [{Find a value in a series and return the next value, or NONE} series [series! any-object! map! none!] value [any-type!] /part "Limit the length of the search" length [number! series!] /only "Treat a series search value as a single value" /case "Perform a case-sensitive search" /same {Use "same?" as comparator} /any "TBD: Use * and ? wildcards in string searches" /with "TBD: Use custom wildcards in place of * and ?" wild [string!] /skip "Treat the series as fixed size records" size [integer!] /last "Find the last occurrence of value, from the tail" /reverse {Find the last occurrence of value, from the current index} return: [any-type!]] [/part 1 1 /only 2 0 /case 3 0 /same 4 0 /any 5 0 /with 6 1 /skip 7 1 /last 8 0 /reverse 9 0]] 
        sort [action! 1 [{Sorts a series (modified); default sort order is ascending} series [series! port!] /case "Perform a case-sensitive sort" /skip "Treat the series as fixed size records" size [integer!] /compare "Comparator offset, block (TBD) or function" comparator [integer! block! any-function!] /part "Sort only part of a series" length [number! series!] /all "Compare all fields (used with /skip)" /reverse "Reverse sort order" /stable "Stable sorting" return: [series!]] [/case 1 0 /skip 2 1 /compare 3 1 /part 4 1 /all 5 0 /reverse 6 0 /stable 7 0]] 
        skip [action! 2 ["Returns the series relative to the current index" series [series! port!] offset [integer! pair!] return: [series! port!]] #[none]] 
        swap [action! 2 [{Swaps elements between two series or the same series} series1 [series! port!] series2 [series! port!] return: [series! port!]] #[none]] 
        tail [action! 1 ["Returns a series at the index after its last value" series [series! port!] return: [series! port!]] #[none]] 
        tail? [action! 1 ["Returns true if a series is past its last value" series [series! port!] return: [logic!]] #[none]] 
        take [action! 1 ["Removes and returns one or more elements" series [series! port! none!] /part "Specifies a length or end position" length [number! series!] /deep "Copy nested values" /last "Take it from the tail end"] [/part 1 1 /deep 2 0 /last 3 0]] 
        trim [action! 1 ["Removes space from a string or NONE from a block" series [series! port!] /head "Removes only from the head" /tail "Removes only from the tail" /auto "Auto indents lines relative to first line" /lines "Removes all line breaks and extra spaces" /all "Removes all whitespace" /with "Same as /all, but removes characters in 'str'" str [char! string! binary! integer!]] [/head 1 0 /tail 2 0 /auto 3 0 /lines 4 0 /all 5 0 /with 6 1]] 
        create [action! 1 ["Send port a create request" port [port! file! url! block!]] #[none]] 
        close [action! 1 ["Closes a port" port [port!]] #[none]] 
        delete [action! 1 ["Deletes the specified file or empty folder" file [file! port!]] #[none]] 
        open [action! 1 [{Opens a port; makes a new port from a specification if necessary} port [port! file! url! block!] /new "Create new file - if it exists, deletes it" /read "Open for read access" /write "Open for write access" /seek "Optimize for random access" /allow "Specificies right access attributes" access [block!]] [/new 1 0 /read 2 0 /write 3 0 /seek 4 0 /allow 5 1]] 
        open? [action! 1 ["Returns TRUE if port is open" port [port!]] #[none]] 
        query [action! 1 ["Returns information about a file" target [file! port!]] #[none]] 
        read [action! 1 ["Reads from a file, URL, or other port" source [file! url! port!] /part {Partial read a given number of units (source relative)} length [number!] /seek "Read from a specific position (source relative)" index [number!] /binary "Preserves contents exactly" /lines "Convert to block of strings" /info /as {Read with the specified encoding, default is 'UTF-8} encoding [word!]] [/part 1 1 /seek 2 1 /binary 3 0 /lines 4 0 /info 5 0 /as 6 1]] 
        rename [action! 2 ["Rename a file" from [port! file! url!] to [port! file! url!]] #[none]] 
        update [action! 1 [{Updates external and internal states (normally after read/write)} port [port!]] #[none]] 
        write [action! 2 ["Writes to a file, URL, or other port" destination [file! url! port!] data [any-type!] /binary "Preserves contents exactly" /lines "Write each value in a block as a separate line" /info /append "Write data at end of file" /part "Partial write a given number of units" length [number!] /seek "Write at a specific position" index [number!] /allow "Specifies protection attributes" access [block!] /as {Write with the specified encoding, default is 'UTF-8} encoding [word!]] [/binary 1 0 /lines 2 0 /info 3 0 /append 4 0 /part 5 1 /seek 6 1 /allow 7 1 /as 8 1]] 
        if [intrinsic! 2 [{If conditional expression is truthy, evaluate block; else return NONE} cond [any-type!] then-blk [block!]] #[none]] 
        unless [intrinsic! 2 [{If conditional expression is falsy, evaluate block; else return NONE} cond [any-type!] then-blk [block!]] #[none]] 
        either [intrinsic! 3 [{If conditional expression is truthy, evaluate the first branch; else evaluate the alternative} cond [any-type!] true-blk [block!] false-blk [block!]] #[none]] 
        any [intrinsic! 1 [{Evaluates and returns the first truthy value, if any; else NONE} conds [block!]] #[none]] 
        all [intrinsic! 1 [{Evaluates and returns the last value if all are truthy; else NONE} conds [block!]] #[none]] 
        while [intrinsic! 2 [{Evaluates body as long as condition block evaluates to truthy value} cond [block!] "Condition block to evaluate on each iteration" body [block!] "Block to evaluate on each iteration"] #[none]] 
        until [intrinsic! 1 ["Evaluates body until it is truthy" body [block!]] #[none]] 
        loop [intrinsic! 2 ["Evaluates body a number of times" count [float! integer!] body [block!]] #[none]] 
        repeat [intrinsic! 3 [{Evaluates body a number of times, tracking iteration count} 'word [word!] "Iteration counter; not local to loop" value [float! integer!] "Number of times to evaluate body" body [block!]] #[none]] 
        forever [intrinsic! 1 ["Evaluates body repeatedly forever" body [block!]] #[none]] 
        foreach [intrinsic! 3 ["Evaluates body for each value in a series" 'word [block! word!] "Word, or words, to set on each iteration" series [map! series!] body [block!]] #[none]] 
        forall [intrinsic! 2 ["Evaluates body for all values in a series" 'word [word!] "Word referring to series to iterate over" body [block!]] #[none]] 
        remove-each [intrinsic! 3 [{Removes values for each block that returns truthy value} 'word [block! word!] "Word or block of words to set each time" data [series!] "The series to traverse (modified)" body [block!] "Block to evaluate (return truthy value to remove)"] #[none]] 
        func [intrinsic! 2 ["Defines a function with a given spec and body" spec [block!] body [block!]] #[none]] 
        function [intrinsic! 2 [{Defines a function, making all set-words found in body, local} spec [block!] body [block!] /extern "Exclude words that follow this refinement"] [/extern 1 0]] 
        does [intrinsic! 1 [{Defines a function with no arguments or local variables} body [block!]] #[none]] 
        has [intrinsic! 2 [{Defines a function with local variables, but no arguments} vars [block!] body [block!]] #[none]] 
        switch [intrinsic! 2 [{Evaluates the first block following the value found in cases} value [any-type!] "The value to match" cases [block!] /default {Specify a default block, if value is not found in cases} case [block!] "Default block to evaluate"] [/default 1 1]] 
        case [intrinsic! 1 [{Evaluates the block following the first truthy condition} cases [block!] "Block of condition-block pairs" /all {Test all conditions, evaluating the block following each truthy condition}] [/all 1 0]] 
        do [native! 1 [{Evaluates a value, returning the last evaluation result} value [any-type!] /expand "Expand directives before evaluation" /args {If value is a script, this will set its system/script/args} arg "Args passed to a script (normally a string)" /next {Do next expression only, return it, update block word} position [word!] "Word updated with new block position"] [/expand 1 0 /args 2 1 /next 3 1]] 
        reduce [intrinsic! 1 [{Returns a copy of a block, evaluating all expressions} value [any-type!] /into {Put results in out block, instead of creating a new block} out [any-block!] "Target block for results, when /into is used"] [/into 1 1]] 
        compose [native! 1 ["Returns a copy of a block, evaluating only parens" value [block!] /deep "Compose nested blocks" /only {Compose nested blocks as blocks containing their values} /into {Put results in out block, instead of creating a new block} out [any-block!] "Target block for results, when /into is used"] [/deep 1 0 /only 2 0 /into 3 1]] 
        get [intrinsic! 1 ["Returns the value a word refers to" word [any-path! any-word! object!] /any {If word has no value, return UNSET rather than causing an error} /case "Use case-sensitive comparison (path only)" return: [any-type!]] [/any 1 0 /case 2 0]] 
        set [intrinsic! 2 ["Sets the value(s) one or more words refer to" word [any-path! any-word! block! object!] "Word, object, map path or block of words to set" value [any-type!] "Value or block of values to assign to words" /any {Allow UNSET as a value rather than causing an error} /case "Use case-sensitive comparison (path only)" /only {Block or object value argument is set as a single value} /some {None values in a block or object value argument, are not set} return: [any-type!]] [/any 1 0 /case 2 0 /only 3 0 /some 4 0]] 
        print [native! 1 ["Outputs a value followed by a newline" value [any-type!]] #[none]] 
        prin [native! 1 ["Outputs a value" value [any-type!]] #[none]] 
        equal? [native! 2 ["Returns TRUE if two values are equal" value1 [any-type!] value2 [any-type!]] #[none]] 
        not-equal? [native! 2 ["Returns TRUE if two values are not equal" value1 [any-type!] value2 [any-type!]] #[none]] 
        strict-equal? [native! 2 [{Returns TRUE if two values are equal, and also the same datatype} value1 [any-type!] value2 [any-type!]] #[none]] 
        lesser? [native! 2 [{Returns TRUE if the first value is less than the second} value1 [any-type!] value2 [any-type!]] #[none]] 
        greater? [native! 2 [{Returns TRUE if the first value is greater than the second} value1 [any-type!] value2 [any-type!]] #[none]] 
        lesser-or-equal? [native! 2 [{Returns TRUE if the first value is less than or equal to the second} value1 [any-type!] value2 [any-type!]] #[none]] 
        greater-or-equal? [native! 2 [{Returns TRUE if the first value is greater than or equal to the second} value1 [any-type!] value2 [any-type!]] #[none]] 
        same? [native! 2 ["Returns TRUE if two values have the same identity" value1 [any-type!] value2 [any-type!]] #[none]] 
        not [native! 1 [{Returns the logical complement of a value (truthy or falsy)} value [any-type!]] #[none]] 
        type? [native! 1 ["Returns the datatype of a value" value [any-type!] /word "Return a word value, rather than a datatype value"] [/word 1 0]] 
        stats [native! 0 ["Returns interpreter statistics" /show "TBD:" /info "Output formatted results" return: [integer! block!]] [/show 1 0 /info 2 0]] 
        bind [native! 2 ["Bind words to a context; returns rebound words" word [any-word! block!] context [any-object! any-word! function!] /copy "Deep copy blocks before binding" return: [block! any-word!]] [/copy 1 0]] 
        in [native! 2 [{Returns the given word bound to the object's context} object [any-object!] word [any-word!]] #[none]] 
        parse [native! 2 ["Process a series using dialected grammar rules" input [any-block! any-string! binary!] rules [block!] /case "Uses case-sensitive comparison" /part "Limit to a length or position" length [number! series!] /trace callback [function! [
                        event [word!] 
                        match? [logic!] 
                        rule [block!] 
                        input [series!] 
                        stack [block!] 
                        return: [logic!]
                    ]] return: [logic! block!]] [/case 1 0 /part 2 1 /trace 3 1]] 
        union [native! 2 ["Returns the union of two data sets" set1 [bitset! block! hash! string! typeset!] set2 [bitset! block! hash! string! typeset!] /case "Use case-sensitive comparison" /skip "Treat the series as fixed size records" size [integer!] return: [block! hash! string! bitset! typeset!]] [/case 1 0 /skip 2 1]] 
        unique [native! 1 ["Returns the data set with duplicates removed" set [block! hash! string!] /case "Use case-sensitive comparison" /skip "Treat the series as fixed size records" size [integer!] return: [block! hash! string!]] [/case 1 0 /skip 2 1]] 
        intersect [native! 2 ["Returns the intersection of two data sets" set1 [bitset! block! hash! string! typeset!] set2 [bitset! block! hash! string! typeset!] /case "Use case-sensitive comparison" /skip "Treat the series as fixed size records" size [integer!] return: [block! hash! string! bitset! typeset!]] [/case 1 0 /skip 2 1]] 
        difference [native! 2 ["Returns the special difference of two data sets" set1 [bitset! block! date! hash! string! typeset!] set2 [bitset! block! date! hash! string! typeset!] /case "Use case-sensitive comparison" /skip "Treat the series as fixed size records" size [integer!] return: [block! hash! string! bitset! typeset! time!]] [/case 1 0 /skip 2 1]] 
        exclude [native! 2 [{Returns the first data set less the second data set} set1 [bitset! block! hash! string! typeset!] set2 [bitset! block! hash! string! typeset!] /case "Use case-sensitive comparison" /skip "Treat the series as fixed size records" size [integer!] return: [block! hash! string! bitset! typeset!]] [/case 1 0 /skip 2 1]] 
        complement? [native! 1 ["Returns TRUE if the bitset is complemented" bits [bitset!]] #[none]] 
        dehex [native! 1 ["Converts URL-style hex encoded (%xx) strings" value [any-string!] return: [string!] "Always return a string"] #[none]] 
        enhex [native! 1 ["Encode URL-style hex encoded (%xx) strings" value [any-string!] return: [string!] "Always return a string"] #[none]] 
        negative? [native! 1 ["Returns TRUE if the number is negative" number [money! number! time!] return: [logic!]] #[none]] 
        positive? [native! 1 ["Returns TRUE if the number is positive" number [money! number! time!] return: [logic!]] #[none]] 
        max [native! 2 ["Returns the greater of the two values" value1 [scalar! series!] value2 [scalar! series!]] #[none]] 
        min [native! 2 ["Returns the lesser of the two values" value1 [scalar! series!] value2 [scalar! series!]] #[none]] 
        shift [native! 2 [{Perform a bit shift operation. Right shift (decreasing) by default} data [integer!] bits [integer!] /left "Shift bits to the left (increasing)" /logical "Use logical shift (unsigned, fill with zero)" return: [integer!]] [/left 1 0 /logical 2 0]] 
        to-hex [native! 1 [{Converts numeric value to a hex issue! datatype (with leading # and 0's)} value [integer!] /size "Specify number of hex digits in result" length [integer!] return: [issue!]] [/size 1 1]] 
        sine [native! 1 ["Returns the trigonometric sine" angle [number!] /radians "Angle is specified in radians" return: [float!]] [/radians 1 0]] 
        cosine [native! 1 ["Returns the trigonometric cosine" angle [number!] /radians "Angle is specified in radians" return: [float!]] [/radians 1 0]] 
        tangent [native! 1 ["Returns the trigonometric tangent" angle [number!] /radians "Angle is specified in radians" return: [float!]] [/radians 1 0]] 
        arcsine [native! 1 [{Returns the trigonometric arcsine (in degrees by default in range [-90,90])} sine [number!] "in range [-1,1]" /radians "Angle is returned in radians [-pi/2,pi/2]" return: [float!]] [/radians 1 0]] 
        arccosine [native! 1 [{Returns the trigonometric arccosine (in degrees by default in range [0,180])} cosine [number!] "in range [-1,1]" /radians "Angle is returned in radians [0,pi]" return: [float!]] [/radians 1 0]] 
        arctangent [native! 1 [{Returns the trigonometric arctangent (in degrees by default in range [-90,90])} tangent [number!] "in range [-inf,+inf]" /radians "Angle is returned in radians [-pi/2,pi/2]" return: [float!]] [/radians 1 0]] 
        arctangent2 [native! 2 [{Returns the smallest angle between the vectors (1,0) and (x,y) in degrees by default (-180,180]} y [number!] x [number!] /radians "Angle is returned in radians (-pi,pi]" return: [float!]] [/radians 1 0]] 
        NaN? [native! 1 ["Returns TRUE if the number is Not-a-Number" value [number!] return: [logic!]] #[none]] 
        zero? [native! 1 ["Returns TRUE if the value is zero" value [char! money! number! pair! time! tuple!] return: [logic!]] #[none]] 
        log-2 [native! 1 ["Return the base-2 logarithm" value [number!] return: [float!]] #[none]] 
        log-10 [native! 1 ["Returns the base-10 logarithm" value [number!] return: [float!]] #[none]] 
        log-e [native! 1 [{Returns the natural (base-E) logarithm of the given value} value [number!] return: [float!]] #[none]] 
        exp [native! 1 [{Raises E (the base of natural logarithm) to the power specified} value [number!] return: [float!]] #[none]] 
        square-root [native! 1 ["Returns the square root of a number" value [number!] return: [float!]] #[none]] 
        construct [intrinsic! 1 [{Makes a new object from an unevaluated spec; standard logic words are evaluated} block [block!] /with "Use a prototype object" object [object!] "Prototype object" /only "Don't evaluate standard logic words"] [/with 1 1 /only 2 0]] 
        value? [native! 1 ["Returns TRUE if the word has a value" value return: [logic!]] #[none]] 
        try [intrinsic! 1 [{Tries to DO a block and returns its value or an error} block [block!] /all {Catch also BREAK, CONTINUE, RETURN, EXIT and THROW exceptions}] [/all 1 0]] 
        uppercase [native! 1 ["Converts string of characters to uppercase" string [any-string! char!] "Value to convert (modified when series)" /part "Limits to a given length or position" limit [any-string! number!] return: [any-string! char!]] [/part 1 1]] 
        lowercase [native! 1 ["Converts string of characters to lowercase" string [any-string! char!] "Value to convert (modified when series)" /part "Limits to a given length or position" limit [any-string! number!] return: [any-string! char!]] [/part 1 1]] 
        as-pair [native! 2 ["Combine X and Y values into a pair" x [float! integer!] y [float! integer!]] #[none]] 
        as-money [native! 2 [{Combine currency code and amount into a monetary value} currency [word!] amount [float! integer!] return: [money!]] #[none]] 
        break [intrinsic! 0 [{Breaks out of a loop, while, until, repeat, foreach, etc} /return "Forces the loop function to return a value" value [any-type!]] [/return 1 1]] 
        continue [intrinsic! 0 ["Throws control back to top of loop"] #[none]] 
        exit [intrinsic! 0 ["Exits a function, returning no value"] #[none]] 
        return [intrinsic! 1 ["Returns a value from a function" value [any-type!]] #[none]] 
        throw [native! 1 ["Throws control back to a previous catch" value [any-type!] "Value returned from catch" /name "Throws to a named catch" word [word!]] [/name 1 1]] 
        catch [native! 1 ["Catches a throw from a block and returns its value" block [block!] "Block to evaluate" /name "Catches a named throw" word [block! word!] "One or more names"] [/name 1 1]] 
        extend [native! 2 [{Extend an object or map value with list of key and value pairs} obj [map! object!] spec [block! hash! map!] /case "Use case-sensitive comparison"] [/case 1 0]] 
        debase [native! 1 [{Decodes binary-coded string (BASE-64 default) to binary value} value [string!] "The string to decode" /base "Binary base to use" base-value [integer!] "The base to convert from: 64, 58, 16, or 2"] [/base 1 1]] 
        enbase [native! 1 [{Encodes a string into a binary-coded string (BASE-64 default)} value [binary! string!] "If string, will be UTF8 encoded" /base "Binary base to use" base-value [integer!] "The base to convert from: 64, 58, 16, or 2"] [/base 1 1]] 
        to-local-file [native! 1 [{Converts a Red file path to the local system file path} path [file! string!] /full {Prepends current dir for full path (for relative paths only)} return: [string!]] [/full 1 0]] 
        wait [native! 1 ["Waits for a duration in seconds or specified time" value [block! none! number! time!] /all "Returns all events in a block"] [/all 1 0]] 
        checksum [native! 2 ["Computes a checksum, CRC, hash, or HMAC" data [binary! file! string!] method [word!] {MD5 SHA1 SHA256 SHA384 SHA512 CRC32 TCP ADLER32 hash} /with {Extra value for HMAC key or hash table size; not compatible with TCP/CRC32/ADLER32 methods} spec [any-string! binary! integer!] {String or binary for MD5/SHA* HMAC key, integer for hash table size} return: [integer! binary!]] [/with 1 1]] 
        unset [native! 1 ["Unsets the value of a word in its current context" word [block! word!] "Word or block of words"] #[none]] 
        new-line [native! 2 [{Sets or clears the new-line marker within a list series} position [any-list!] "Position to change marker (modified)" value [logic!] "Set TRUE for newline" /all "Set/clear marker to end of series" /skip {Set/clear marker periodically to the end of the series} size [integer!] return: [any-list!]] [/all 1 0 /skip 2 1]] 
        new-line? [native! 1 [{Returns the state of the new-line marker within a list series} position [any-list!] "Position to change marker" return: [any-list!]] #[none]] 
        context? [native! 1 ["Returns the context to which a word is bound" word [any-word!] "Word to check" return: [object! function! none!]] #[none]] 
        set-env [native! 2 [{Sets the value of an operating system environment variable (for current process)} var [any-string! any-word!] "Variable to set" value [none! string!] "Value to set, or NONE to unset it"] #[none]] 
        get-env [native! 1 [{Returns the value of an OS environment variable (for current process)} var [any-string! any-word!] "Variable to get" return: [string! none!]] #[none]] 
        list-env [native! 0 [{Returns a map of OS environment variables (for current process)} return: [map!]] #[none]] 
        now [native! 0 ["Returns date and time" /year "Returns year only" /month "Returns month only" /day "Returns day of the month only" /time "Returns time only" /zone "Returns time zone offset from UTC (GMT) only" /date "Returns date only" /weekday {Returns day of the week as integer (Monday is day 1)} /yearday "Returns day of the year (Julian)" /precise "High precision time" /utc "Universal time (no zone)" return: [date! time! integer!]] [/year 1 0 /month 2 0 /day 3 0 /time 4 0 /zone 5 0 /date 6 0 /weekday 7 0 /yearday 8 0 /precise 9 0 /utc 10 0]] 
        sign? [native! 1 [{Returns sign of N as 1, 0, or -1 (to use as a multiplier)} number [money! number! time!] return: [integer!]] #[none]] 
        as [native! 2 [{Coerce a series into a compatible datatype without copying it} type [any-path! any-string! block! datatype! paren!] "The datatype or example value" spec [any-path! any-string! block! paren!] "The series to coerce"] #[none]] 
        call [native! 1 ["Executes a shell command to run another process" cmd [file! string!] "A shell command or an executable file" /wait "Runs command and waits for exit" /show {Force the display of system's shell window (Windows only)} /console {Runs command with I/O redirected to console (CLI console only at present)} /shell "Forces command to be run from shell" /input in [binary! file! string!] "Redirects in to stdin" /output out [binary! file! string!] "Redirects stdout to out" /error err [binary! file! string!] "Redirects stderr to err" return: [integer!] "0 if success, -1 if error, or a process ID"] [/wait 1 0 /show 2 0 /console 3 0 /shell 4 0 /input 5 1 /output 6 1 /error 7 1]] 
        size? [native! 1 ["Returns the size of a file content" file [file!] return: [integer! none!]] #[none]] 
        browse [native! 1 [{Open web browser to a URL or file mananger to a local file} url [file! url!]] #[none]] 
        compress [native! 1 [{compresses data. return GZIP format (RFC 1952) by default} data [any-string! binary!] /zlib "Return ZLIB format (RFC 1950)" /deflate "Return DEFLATE format (RFC 1951)"] [/zlib 1 0 /deflate 2 0]] 
        decompress [native! 1 [{Decompresses data. Data in GZIP format (RFC 1952) by default} data [binary!] /zlib "Data in ZLIB format (RFC 1950)" size [integer!] "Uncompressed data size. Use 0 if don't know" /deflate "Data in DEFLATE format (RFC 1951)" size [integer!] "Uncompressed data size. Use 0 if don't know"] [/zlib 1 1 /deflate 2 1]] 
        recycle [native! 0 ["Recycles unused memory" /on "Turns on garbage collector" /off "Turns off garbage collector"] [/on 1 0 /off 2 0]] 
        transcode [native! 1 [{Translates UTF-8 binary source to values. Returns one or several values in a block} src [binary! string!] {UTF-8 input buffer; string argument will be UTF-8 encoded} /next {Translate next complete value (blocks as single value)} /one {Translate next complete value, returns the value only} /prescan {Prescans only, do not load values. Returns guessed type.} /scan {Scans only, do not load values. Returns recognized type.} /part "Translates only part of the input buffer" length [binary! integer!] "Length in bytes or tail position" /into "Optionally provides an output block" dst [block! none!] /trace callback [function! [
                        event [word!] 
                        input [binary! string!] 
                        type [word! datatype!] 
                        line [integer!] 
                        token 
                        return: [logic!]
                    ]] return: [block!]] [/next 1 0 /one 2 0 /prescan 3 0 /scan 4 0 /part 5 1 /into 6 1 /trace 7 1]] 
        quit-return [routine! 1 [
                status #[block![2 1x1 integer!]3]
            ] #[none]] 
        set-quiet [routine! 2 [
                word #[block![2 1x1 red/cell!]3] 
                value #[block![2 1x1 red/cell!]3] 
                /local 
                w #[block![2 1x1 red-word!]3] 
                type #[block![2 1x1 integer!]3] 
                node #[block![2 1x1 pointer! #[block![2 1x1 integer!]3]]3]
            ] #[none]] 
        set-slot-quiet [routine! 2 [
                series #[block![2 576x1 red/cell!]3] 
                value #[block![2 576x1 red/cell!]3] 
                /local 
                blk #[block![2 576x1 red-block!]3] 
                type #[block![2 576x1 integer!]3]
            ] #[none]] 
        shift-right [routine! 2 ["Shift bits to the right" data #[block![2 576x1 integer!]3] bits #[block![2 576x1 integer!]3]] #[none]] 
        shift-left [routine! 2 [data #[block![2 576x1 integer!]3] bits #[block![2 576x1 integer!]3]] #[none]] 
        shift-logical [routine! 2 ["Shift bits to the right (unsigned)" data #[block![2 576x1 integer!]3] bits #[block![2 576x1 integer!]3]] #[none]] 
        last-lf? [routine! 0 ["Internal Use Only" /local bool #[block![2 576x1 red-logic!]3]] #[none]] 
        get-current-dir [routine! 0 [] #[none]] 
        set-current-dir [routine! 1 [path #[block![2 576x1 red-string!]3] /local dir #[block![2 576x1 red-file!]3]] #[none]] 
        create-dir [routine! 1 [path #[block![2 576x1 red-file!]3]] #[none]] 
        exists? [routine! 1 [path #[block![2 576x1 red-file!]3] return: #[block![2 576x1 logic!]3]] #[none]] 
        os-info [routine! 0 [{Returns detailed operating system version information}] #[none]] 
        as-color [routine! 3 [
                r #[block![2 576x1 integer!]3] 
                g #[block![2 576x1 integer!]3] 
                b #[block![2 576x1 integer!]3] 
                /local 
                arr1 #[block![2 576x1 integer!]3] 
                err #[block![2 576x1 integer!]3]
            ] #[none]] 
        as-ipv4 [routine! 4 [
                a #[block![2 576x1 integer!]3] 
                b #[block![2 576x1 integer!]3] 
                c #[block![2 576x1 integer!]3] 
                d #[block![2 576x1 integer!]3] 
                /local 
                arr1 #[block![2 576x1 integer!]3] 
                err #[block![2 576x1 integer!]3]
            ] #[none]] 
        as-rgba [routine! 4 [
                a #[block![2 576x1 integer!]3] 
                b #[block![2 576x1 integer!]3] 
                c #[block![2 576x1 integer!]3] 
                d #[block![2 576x1 integer!]3] 
                /local 
                arr1 #[block![2 576x1 integer!]3] 
                err #[block![2 576x1 integer!]3]
            ] #[none]] 
        count-chars [routine! 2 [
                {Count UTF-8 encoded characters between two positions in a binary series} 
                start #[block![2 576x1 red-binary!]3] 
                pos #[block![2 576x1 red-binary!]3] 
                return: #[block![2 576x1 integer!]3] 
                /local 
                p tail #[block![2 576x1 pointer! #[block![2 576x1 byte!]3]]3] 
                c len #[block![2 576x1 integer!]3] 
                s #[block![2 576x1 red/series-buffer!]3]
            ] #[none]] 
        read-clipboard [routine! 0 [
                "Return the contents of the system clipboard" 
                return: #[block![2 576x1 red/cell!]3] {false on failure, none if empty, otherwise: string!, block! of files!, or an image!}
            ] #[none]] 
        write-clipboard [routine! 1 [
                "Write content to the system clipboard" 
                data #[block![2 576x1 red/cell!]3] "string!, block! of files!, an image! or none!" 
                return: #[block![2 576x1 logic!]3] "indicates success"
            ] #[none]] 
        write-stdout [routine! 1 ["Write data to STDOUT" data #[block![2 576x1 red/cell!]3]] #[none]] 
        routine [function! 2 [{Defines a function with a given Red spec and Red/System body} spec [block!] body [block!]] #[none]] 
        alert [function! 1 [msg [block! string!]] #[none]] 
        also [function! 2 [
                {Returns the first value, but also evaluates the second} 
                value1 [any-type!] 
                value2 [any-type!]
            ] #[none]] 
        attempt [function! 1 [
                {Tries to evaluate a block and returns result or NONE on error} 
                value [block!] 
                /safer "Capture all possible errors and exceptions"
            ] [
                /safer 1 0
            ]] 
        comment [function! 1 ["Consume but don't evaluate the next value" 'value] #[none]] 
        quit [function! 0 [
                "Stops evaluation and exits the program" 
                /return status [integer!] "Return an exit status"
            ] [
                /return 1 1
            ]] 
        empty? [function! 1 [
                {Returns true if a series is at its tail or a map! is empty} 
                series [map! none! series!] 
                return: [logic!]
            ] #[none]] 
        ?? [function! 1 [
                "Prints a word and the value it refers to (molded)" 
                'value [path! word!]
            ] #[none]] 
        probe [function! 1 [
                "Returns a value after printing its molded form" 
                value [any-type!]
            ] #[none]] 
        quote [function! 1 [
                "Return but don't evaluate the next value" 
                :value
            ] #[none]] 
        first [function! 1 ["Returns the first value in a series" s [date! pair! series! time! tuple!]] #[none]] 
        second [function! 1 ["Returns the second value in a series" s [date! pair! series! time! tuple!]] #[none]] 
        third [function! 1 ["Returns the third value in a series" s [date! series! time! tuple!]] #[none]] 
        fourth [function! 1 ["Returns the fourth value in a series" s [date! series! tuple!]] #[none]] 
        fifth [function! 1 ["Returns the fifth value in a series" s [date! series! tuple!]] #[none]] 
        last [function! 1 ["Returns the last value in a series" s [series! tuple!]] #[none]] 
        spec-of [function! 1 [{Returns the spec of a value that supports reflection} value] #[none]] 
        body-of [function! 1 [{Returns the body of a value that supports reflection} value] #[none]] 
        words-of [function! 1 [{Returns the list of words of a value that supports reflection} value] #[none]] 
        class-of [function! 1 ["Returns the class ID of an object" value] #[none]] 
        values-of [function! 1 [{Returns the list of values of a value that supports reflection} value] #[none]] 
        bitset? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        binary? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        block? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        char? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        email? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        file? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        float? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        get-path? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        get-word? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        hash? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        integer? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        issue? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        lit-path? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        lit-word? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        logic? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        map? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        none? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        pair? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        paren? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        path? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        percent? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        refinement? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        set-path? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        set-word? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        string? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        tag? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        time? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        typeset? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        tuple? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        unset? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        url? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        word? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        image? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        date? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        money? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        ref? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        handle? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        error? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        action? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        native? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        datatype? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        function? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        object? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        op? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        routine? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        vector? [function! 1 
            ["Returns true if the value is this type" value [any-type!]] #[none]
        ] 
        any-list? [function! 1 ["Returns true if the value is any type of any-list" value [any-type!]] #[none]] 
        any-block? [function! 1 ["Returns true if the value is any type of any-block" value [any-type!]] #[none]] 
        any-function? [function! 1 [{Returns true if the value is any type of any-function} value [any-type!]] #[none]] 
        any-object? [function! 1 [{Returns true if the value is any type of any-object} value [any-type!]] #[none]] 
        any-path? [function! 1 ["Returns true if the value is any type of any-path" value [any-type!]] #[none]] 
        any-string? [function! 1 [{Returns true if the value is any type of any-string} value [any-type!]] #[none]] 
        any-word? [function! 1 ["Returns true if the value is any type of any-word" value [any-type!]] #[none]] 
        series? [function! 1 ["Returns true if the value is any type of series" value [any-type!]] #[none]] 
        number? [function! 1 ["Returns true if the value is any type of number" value [any-type!]] #[none]] 
        immediate? [function! 1 ["Returns true if the value is any type of immediate" value [any-type!]] #[none]] 
        scalar? [function! 1 ["Returns true if the value is any type of scalar" value [any-type!]] #[none]] 
        all-word? [function! 1 ["Returns true if the value is any type of all-word" value [any-type!]] #[none]] 
        to-bitset [function! 1 ["Convert to bitset! value" value] #[none]] 
        to-binary [function! 1 ["Convert to binary! value" value] #[none]] 
        to-block [function! 1 ["Convert to block! value" value] #[none]] 
        to-char [function! 1 ["Convert to char! value" value] #[none]] 
        to-email [function! 1 ["Convert to email! value" value] #[none]] 
        to-file [function! 1 ["Convert to file! value" value] #[none]] 
        to-float [function! 1 ["Convert to float! value" value] #[none]] 
        to-get-path [function! 1 ["Convert to get-path! value" value] #[none]] 
        to-get-word [function! 1 ["Convert to get-word! value" value] #[none]] 
        to-hash [function! 1 ["Convert to hash! value" value] #[none]] 
        to-integer [function! 1 ["Convert to integer! value" value] #[none]] 
        to-issue [function! 1 ["Convert to issue! value" value] #[none]] 
        to-lit-path [function! 1 ["Convert to lit-path! value" value] #[none]] 
        to-lit-word [function! 1 ["Convert to lit-word! value" value] #[none]] 
        to-logic [function! 1 ["Convert to logic! value" value] #[none]] 
        to-map [function! 1 ["Convert to map! value" value] #[none]] 
        to-none [function! 1 ["Convert to none! value" value] #[none]] 
        to-pair [function! 1 ["Convert to pair! value" value] #[none]] 
        to-paren [function! 1 ["Convert to paren! value" value] #[none]] 
        to-path [function! 1 ["Convert to path! value" value] #[none]] 
        to-percent [function! 1 ["Convert to percent! value" value] #[none]] 
        to-refinement [function! 1 ["Convert to refinement! value" value] #[none]] 
        to-set-path [function! 1 ["Convert to set-path! value" value] #[none]] 
        to-set-word [function! 1 ["Convert to set-word! value" value] #[none]] 
        to-string [function! 1 ["Convert to string! value" value] #[none]] 
        to-tag [function! 1 ["Convert to tag! value" value] #[none]] 
        to-time [function! 1 ["Convert to time! value" value] #[none]] 
        to-typeset [function! 1 ["Convert to typeset! value" value] #[none]] 
        to-tuple [function! 1 ["Convert to tuple! value" value] #[none]] 
        to-unset [function! 1 ["Convert to unset! value" value] #[none]] 
        to-url [function! 1 ["Convert to url! value" value] #[none]] 
        to-word [function! 1 ["Convert to word! value" value] #[none]] 
        to-image [function! 1 ["Convert to image! value" value] #[none]] 
        to-date [function! 1 ["Convert to date! value" value] #[none]] 
        to-money [function! 1 ["Convert to money! value" value] #[none]] 
        to-ref [function! 1 ["Convert to ref! value" value] #[none]] 
        context [function! 1 [
                "Makes a new object from an evaluated spec" 
                spec [block!]
            ] #[none]] 
        alter [function! 2 [
                {If a value is not found in a series, append it; otherwise, remove it. Returns true if added} 
                series [series!] 
                value
            ] #[none]] 
        offset? [function! 2 [
                "Returns the offset between two series positions" 
                series1 [series!] 
                series2 [series!]
            ] #[none]] 
        repend [function! 2 [
                {Appends a reduced value to a series and returns the series head} 
                series [series!] 
                value 
                /only "Appends a block value as a block"
            ] [
                /only 1 0
            ]] 
        replace [function! 3 [
                "Replaces values in a series, in place" 
                series [any-block! any-string! binary! vector!] "The series to be modified" 
                pattern "Specific value or parse rule pattern to match" 
                value "New value, replaces pattern in the series" 
                /all "Replace all occurrences, not just the first" 
                /deep "Replace pattern in all sub-lists as well" 
                /case "Case-sensitive replacement" 
                /local parse? form? quote? deep? rule many? size seek
            ] [
                /all 1 0 
                /deep 2 0 
                /case 3 0
            ]] 
        math [function! 1 [
                "Evaluates expression using math precedence rules" 
                datum [block! paren!] "Expression to evaluate" 
                /local match 
                order infix tally enter recur count operator
            ] #[none]] 
        charset [function! 1 [
                "Shortcut for `make bitset!`" 
                spec [binary! bitset! block! char! integer! string!]
            ] #[none]] 
        ctx||175~on-parse-event [function! 5 [
                "Standard parse/trace callback used by PARSE-TRACE" 
                event [word!] {Trace events: push, pop, fetch, match, iterate, paren, end} 
                match? [logic!] "Result of last matching operation" 
                rule [block!] "Current rule at current position" 
                input [series!] "Input series at next position to match" 
                stack [block!] "Internal parse rules stack" 
                return: [logic!] {TRUE: continue parsing, FALSE: stop and exit parsing}
            ] #[none]] 
        parse-trace [function! 2 [
                {Wrapper for parse/trace using the default event processor} 
                input [series!] 
                rules [block!] 
                /case "Uses case-sensitive comparison" 
                /part "Limit to a length or position" 
                limit [integer!] 
                return: [logic! block!]
            ] [
                /case 1 0 
                /part 2 1
            ] ctx||175] 
        suffix? [function! 1 [
                {Returns the suffix (extension) of a filename or url, or NONE if there is no suffix} 
                path [email! file! string! url!]
            ] #[none]] 
        scan [function! 1 [
                {Returns the guessed type of the first serialized value from the input} 
                buffer [binary! string!] "Input UTF-8 buffer or string" 
                /next {Returns both the type and the input after the value} 
                /fast "Fast scanning, returns best guessed type" 
                return: [datatype! none!] "Recognized or guessed type, or NONE on empty input"
            ] [
                /next 1 0 
                /fast 2 0
            ]] 
        load [function! 1 [
                {Returns a value or block of values by reading and evaluating a source} 
                source [binary! file! string! url!] 
                /header "TBD" 
                /all {Load all values, returns a block. TBD: Don't evaluate Red header} 
                /trap "Load all values, returns [[values] position error]" 
                /next {Load the next value only, updates source series word} 
                position [word!] "Word updated with new series position" 
                /part "Limit to a length or position" 
                length [integer! string!] 
                /into {Put results in out block, instead of creating a new block} 
                out [block!] "Target block for results" 
                /as "Specify the type of data; use NONE to load as code" 
                type [none! word!] "E.g. bmp, gif, jpeg, png" 
                /local codec suffix name mime pre-load
            ] [
                /header 1 0 
                /all 2 0 
                /trap 3 0 
                /next 4 1 
                /part 5 1 
                /into 6 1 
                /as 7 1
            ]] 
        save [function! 2 [
                {Saves a value, block, or other data to a file, URL, binary, or string} 
                where [binary! file! none! string! url!] "Where to save" 
                value [any-type!] "Value(s) to save" 
                /header {Provide a Red header block (or output non-code datatypes)} 
                header-data [block! object!] 
                /all "TBD: Save in serialized format" 
                /length {Save the length of the script content in the header} 
                /as {Specify the format of data; use NONE to save as plain text} 
                format [none! word!] "E.g. bmp, gif, jpeg, png" 
                /local dst codec data suffix find-encoder? name pos header-str k v
            ] [
                /header 1 1 
                /all 2 0 
                /length 3 0 
                /as 4 1
            ]] 
        cause-error [function! 3 [
                {Causes an immediate error throw, with the provided information} 
                err-type [word!] 
                err-id [word!] 
                args [block! string!]
            ] #[none]] 
        pad [function! 2 [
                "Pad a FORMed value on right side with spaces" 
                str "Value to pad, FORM it if not a string" 
                n [integer!] "Total size (in characters) of the new string" 
                /left "Pad the string on left side" 
                /with "Pad with char" 
                c [char!] 
                return: [string!] "Modified input string at head"
            ] [
                /left 1 0 
                /with 2 1
            ]] 
        mod [function! 2 [
                "Compute a nonnegative remainder of A divided by B" 
                a [char! money! number! pair! time! tuple! vector!] 
                b [char! money! number! pair! time! tuple! vector!] "Must be nonzero" 
                return: [number! money! char! pair! tuple! vector! time!] 
                /local r
            ] #[none]] 
        modulo [function! 2 [
                {Wrapper for MOD that handles errors like REMAINDER. Negligible values (compared to A and B) are rounded to zero} 
                a [char! money! number! pair! time! tuple! vector!] 
                b [char! money! number! pair! time! tuple! vector!] 
                return: [number! money! char! pair! tuple! vector! time!] 
                /local r
            ] #[none]] 
        eval-set-path [function! 1 ["Internal Use Only" value1] #[none]] 
        to-red-file [function! 1 [
                {Converts a local system file path to a Red file path} 
                path [file! string!] 
                return: [file!] 
                /local colon? slash? len i c dst
            ] #[none]] 
        dir? [function! 1 [{Returns TRUE if the value looks like a directory spec} file [file! url!]] #[none]] 
        normalize-dir [function! 1 [
                "Returns an absolute directory spec" 
                dir [file! path! word!]
            ] #[none]] 
        what-dir [function! 0 [
                "Returns the active directory path" 
                /local path
            ] #[none]] 
        change-dir [function! 1 [
                "Changes the active directory path" 
                dir [file! path! word!] {New active directory of relative path to the new one}
            ] #[none]] 
        make-dir [function! 1 [
                {Creates the specified directory. No error if already exists} 
                path [file!] 
                /deep "Create subdirectories too" 
                /local dirs end created dir
            ] [
                /deep 1 0
            ]] 
        extract [function! 2 [
                {Extracts a value from a series at regular intervals} 
                series [series!] 
                width [integer!] "Size of each entry (the skip)" 
                /index "Extract from an offset position" 
                pos [integer!] "The position" 
                /into {Provide an output series instead of creating a new one} 
                output [series!] "Output series"
            ] [
                /index 1 1 
                /into 2 1
            ]] 
        extract-boot-args [function! 0 [
                {Process command-line arguments and store values in system/options (internal usage)} 
                /local args at-arg2 ws buf s
            ] #[none]] 
        collect [function! 1 [
                {Collect in a new block all the values passed to KEEP function from the body block} 
                body [block!] "Block to evaluate" 
                /into {Insert into a buffer instead (returns position after insert)} 
                collected [series!] "The buffer series (modified)" 
                /local keep rule pos
            ] [
                /into 1 1
            ]] 
        flip-exe-flag [function! 1 [
                {Flip the sub-system for the red.exe between console and GUI modes (Windows only)} 
                path [file!] "Path to the red.exe" 
                /local file buffer flag
            ] #[none]] 
        split [function! 2 [
                {Break a string series into pieces using the provided delimiters} 
                series [any-string!] dlm [bitset! char! string!] /local s 
                num
            ] #[none]] 
        dirize [function! 1 [
                "Returns a copy of the path turned into a directory" 
                path [file! string! url!]
            ] #[none]] 
        clean-path [function! 1 [
                {Cleans-up '.' and '..' in path; returns the cleaned path} 
                file [file! string! url!] 
                /only "Do not prepend current directory" 
                /dir "Add a trailing / if missing" 
                /local out cnt f not-file? prot
            ] [
                /only 1 0 
                /dir 2 0
            ]] 
        split-path [function! 1 [
                {Splits a file or URL path. Returns a block containing path and target} 
                target [file! url!] 
                /local dir pos
            ] #[none]] 
        do-file [function! 1 ["Internal Use Only" file [file! url!] 
                /local ws saved src code new-path header list c
            ] #[none]] 
        path-thru [function! 1 [
                "Returns the local disk cache path of a remote file" 
                url [url!] "Remote file address" 
                return: [file!] 
                /local so hash file path
            ] #[none]] 
        exists-thru? [function! 1 [
                {Returns true if the remote file is present in the local disk cache} 
                url [file! url!] "Remote file address"
            ] #[none]] 
        read-thru [function! 1 [
                "Reads a remote file through local disk cache" 
                url [url!] "Remote file address" 
                /update "Force a cache update" 
                /binary "Use binary mode" 
                /local path data
            ] [
                /update 1 0 
                /binary 2 0
            ]] 
        load-thru [function! 1 [
                "Loads a remote file through local disk cache" 
                url [url!] "Remote file address" 
                /update "Force a cache update" 
                /as "Specify the type of data; use NONE to load as code" 
                type [none! word!] "E.g. bmp, gif, jpeg, png" 
                /local path file
            ] [
                /update 1 0 
                /as 2 1
            ]] 
        do-thru [function! 1 [
                {Evaluates a remote Red script through local disk cache} 
                url [url!] "Remote file address" 
                /update "Force a cache update"
            ] [
                /update 1 0
            ]] 
        cos [function! 1 [
                "Returns the trigonometric cosine" 
                angle [float!] "Angle in radians"
            ] #[none]] 
        sin [function! 1 [
                "Returns the trigonometric sine" 
                angle [float!] "Angle in radians"
            ] #[none]] 
        tan [function! 1 [
                "Returns the trigonometric tangent" 
                angle [float!] "Angle in radians"
            ] #[none]] 
        acos [function! 1 [
                {Returns the trigonometric arccosine (in radians in range [0,pi])} 
                cosine [float!] "in range [-1,1]"
            ] #[none]] 
        asin [function! 1 [
                {Returns the trigonometric arcsine (in radians in range [-pi/2,pi/2])} 
                sine [float!] "in range [-1,1]"
            ] #[none]] 
        atan [function! 1 [
                {Returns the trigonometric arctangent (in radians in range [-pi/2,+pi/2])} 
                tangent [float!] "in range [-inf,+inf]"
            ] #[none]] 
        atan2 [function! 2 [
                {Returns the smallest angle between the vectors (1,0) and (x,y) in range (-pi,pi]} 
                y [number!] 
                x [number!] 
                return: [float!]
            ] #[none]] 
        sqrt [function! 1 [
                "Returns the square root of a number" 
                number [number!] 
                return: [float!]
            ] #[none]] 
        to-UTC-date [function! 1 [
                "Returns the date with UTC zone" 
                date [date!] 
                return: [date!]
            ] #[none]] 
        to-local-date [function! 1 [
                "Returns the date with local zone" 
                date [date!] 
                return: [date!]
            ] #[none]] 
        transcode-trace [function! 1 [
                {Shortcut function for transcoding while tracing all lexer events} 
                src [binary! string!]
            ] #[none]] 
        rejoin [function! 1 [
                "Reduces and joins a block of values." 
                block [block!] "Values to reduce and join"
            ] #[none]] 
        sum [function! 1 [
                "Returns the sum of all values in a block" 
                values [block! hash! paren! vector!] 
                /local result value
            ] #[none]] 
        average [function! 1 [
                "Returns the average of all values in a block" 
                block [block! hash! paren! vector!]
            ] #[none]] 
        last? [function! 1 [
                "Returns TRUE if the series length is 1" 
                series [series!]
            ] #[none]] 
        dt [function! 1 [
                "Returns the time required to evaluate a block" 
                body [block!] 
                return: [time!] 
                /local t0
            ] #[none]] 
        single? [function! 1 [
                "Returns TRUE if the series length is 1" 
                series [series!]
            ] #[none]] 
        keys-of [function! 1 [{Returns the list of words of a value that supports reflection} value] #[none]] 
        object [function! 1 [
                "Makes a new object from an evaluated spec" 
                spec [block!]
            ] #[none]] 
        halt [function! 0 [
                "Stops evaluation and exits the program" 
                /return status [integer!] "Return an exit status"
            ] [
                /return 1 1
            ]] 
        ctx||256~interpreted? [function! 0 ["Return TRUE if called from the interpreter"] #[none]] 
        ctx||263~on-change* [function! 3 [word old new] #[none]] 
        ctx||263~on-deep-change* [function! 7 [owner word target action new index part] #[none]] 
        ctx||269~on-change* [function! 3 [word old new] #[none]] 
        ctx||267~on-change* [function! 3 [word old new] #[none]] 
        ctx||267~on-deep-change* [function! 7 [owner word target action new index part] #[none]] 
        ctx||290~lex [function! 5 [
                event [word!] 
                input [binary! string!] 
                type [datatype! none! word!] 
                line [integer!] 
                token 
                return: [logic!]
            ] #[none]] 
        + [op! 2 ["Returns the sum of the two values" value1 [scalar! vector!] "The augend" value2 [scalar! vector!] "The addend" return: [scalar! vector!] "The sum"] #[none]] 
        - [op! 2 ["Returns the difference between two values" value1 [scalar! vector!] "The minuend" value2 [scalar! vector!] "The subtrahend" return: [scalar! vector!] "The difference"] #[none]] 
        * [op! 2 ["Returns the product of two values" value1 [number! money! char! pair! tuple! vector! time!] "The multiplicand" value2 [number! money! char! pair! tuple! vector! time!] "The multiplier" return: [number! money! char! pair! tuple! vector! time!] "The product"] #[none]] 
        / [op! 2 ["Returns the quotient of two values" value1 [number! money! char! pair! tuple! vector! time!] "The dividend (numerator)" value2 [number! money! char! pair! tuple! vector! time!] "The divisor (denominator)" return: [number! money! char! pair! tuple! vector! time!] "The quotient"] #[none]] 
        // [op! 2 [
                {Wrapper for MOD that handles errors like REMAINDER. Negligible values (compared to A and B) are rounded to zero} 
                a [char! money! number! pair! time! tuple! vector!] 
                b [char! money! number! pair! time! tuple! vector!] 
                return: [number! money! char! pair! tuple! vector! time!] 
                /local r
            ] #[none]] 
        %"" [op! 2 [{Returns what is left over when one value is divided by another} value1 [number! money! char! pair! tuple! vector! time!] "The dividend (numerator)" value2 [number! money! char! pair! tuple! vector! time!] "The divisor (denominator)" return: [number! money! char! pair! tuple! vector! time!] "The remainder"] #[none]] 
        = [op! 2 ["Returns TRUE if two values are equal" value1 [any-type!] value2 [any-type!]] #[none]] 
        <> [op! 2 ["Returns TRUE if two values are not equal" value1 [any-type!] value2 [any-type!]] #[none]] 
        == [op! 2 [{Returns TRUE if two values are equal, and also the same datatype} value1 [any-type!] value2 [any-type!]] #[none]] 
        =? [op! 2 ["Returns TRUE if two values have the same identity" value1 [any-type!] value2 [any-type!]] #[none]] 
        < [op! 2 [{Returns TRUE if the first value is less than the second} value1 [any-type!] value2 [any-type!]] #[none]] 
        > [op! 2 [{Returns TRUE if the first value is greater than the second} value1 [any-type!] value2 [any-type!]] #[none]] 
        <= [op! 2 [{Returns TRUE if the first value is less than or equal to the second} value1 [any-type!] value2 [any-type!]] #[none]] 
        >= [op! 2 [{Returns TRUE if the first value is greater than or equal to the second} value1 [any-type!] value2 [any-type!]] #[none]] 
        << [op! 2 [data #[block![2 576x1 integer!]3] bits #[block![2 576x1 integer!]3]] #[none]] 
        >> [op! 2 ["Shift bits to the right" data #[block![2 576x1 integer!]3] bits #[block![2 576x1 integer!]3]] #[none]] 
        ">>>" [op! 2 ["Shift bits to the right (unsigned)" data #[block![2 576x1 integer!]3] bits #[block![2 576x1 integer!]3]] #[none]] 
        ** [op! 2 [{Returns a number raised to a given power (exponent)} number [number!] "Base value" exponent [integer! float!] "The power (index) to raise the base value by" return: [number!]] #[none]] 
        and [op! 2 ["Returns the first value ANDed with the second" value1 [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!] value2 [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!] return: [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]] #[none]] 
        or [op! 2 ["Returns the first value ORed with the second" value1 [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!] value2 [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!] return: [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]] #[none]] 
        xor [op! 2 [{Returns the first value exclusive ORed with the second} value1 [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!] value2 [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!] return: [logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]] #[none]] 
        ctx||294~encode [routine! 2 [img #[block![2 576x1 red-image!]3] where #[block![2 576x1 red/cell!]3]] #[none]] 
        ctx||294~decode [routine! 1 [data #[block![2 576x1 red/cell!]3]] #[none]] 
        ctx||298~encode [routine! 2 [img #[block![2 576x1 red-image!]3] where #[block![2 576x1 red/cell!]3]] #[none]] 
        ctx||298~decode [routine! 1 [data #[block![2 576x1 red/cell!]3]] #[none]] 
        ctx||302~encode [routine! 2 [img #[block![2 576x1 red-image!]3] where #[block![2 576x1 red/cell!]3]] #[none]] 
        ctx||302~decode [routine! 1 [data #[block![2 576x1 red/cell!]3]] #[none]] 
        ctx||306~encode [routine! 2 [img #[block![2 576x1 red-image!]3] where #[block![2 576x1 red/cell!]3]] #[none]] 
        ctx||306~decode [routine! 1 [data #[block![2 576x1 red/cell!]3]] #[none]] 
        ctx||310~encode [function! 2 [data [any-type!] where [file! none! url!]] #[none]] 
        ctx||310~decode [function! 1 [text [binary! file! string!]] #[none]] 
        ctx||319~BOM-UTF-16? [function! 1 [data [binary! string!]] #[none]] 
        ctx||319~BOM-UTF-32? [function! 1 [data [binary! string!]] #[none]] 
        ctx||319~enquote [function! 1 [str [string!] "(modified)"] #[none]] 
        ctx||319~high-surrogate? [function! 1 [codepoint [integer!]] #[none]] 
        ctx||319~low-surrogate? [function! 1 [codepoint [integer!]] #[none]] 
        ctx||319~translit [function! 3 [
                "Transliterate sub-strings in a string" 
                string [string!] "Input (modified)" 
                rule [bitset! block!] "What to change" 
                xlat [block! function!] {Translation table or function. MUST map a string! to a string!.} 
                /local val
            ] #[none]] 
        ctx||319~decode-backslash-escapes [function! 1 [string [string!] "(modified)"] #[none]] 
        ctx||319~encode-backslash-escapes [function! 1 [string [string!] "(modified)"] #[none]] 
        ctx||319~decode-unicode-char [function! 1 [
                {Convert \uxxxx format (NOT simple JSON backslash escapes) to a Unicode char} 
                ch [string!] "4 hex digits"
            ] #[none]] 
        ctx||319~replace-unicode-escapes [function! 1 [
                s [string!] "(modified)" 
                /local c
            ] #[none]] 
        ctx||319~push [function! 1 [val] #[none]] 
        ctx||319~pop [function! 0 [] #[none]] 
        ctx||319~emit [function! 1 [value] #[none]] 
        load-json [function! 1 [
                "Convert a JSON string to Red data" 
                input [string!] "The JSON string"
            ] #[none] ctx||319] 
        ctx||335~init-state [function! 2 [ind ascii?] #[none]] 
        ctx||335~emit-indent [function! 2 [output level] #[none]] 
        ctx||335~emit-key-value [function! 4 [output sep map key 
                /local value
            ] #[none]] 
        ctx||335~red-to-json-value [function! 2 [output value 
                /local special-char mark1 mark2 escape v keys k
            ] #[none]] 
        to-json [function! 1 [
                "Convert Red data to a JSON string" 
                data 
                /pretty indent [string!] "Pretty format the output, using given indentation" 
                /ascii "Force ASCII output (instead of UTF-8)" 
                /local result
            ] [
                /pretty 1 1 
                /ascii 2 0
            ] ctx||335] 
        ctx||343~encode [function! 2 [data [any-type!] where [file! none! url!]] #[none]] 
        ctx||343~decode [function! 1 [text [binary! file! string!]] #[none]] 
        ctx||348~to-csv-line [function! 2 [
                {Join values as a string and put delimiter between them} 
                data [block!] "Series to join" 
                delimiter [char! string!] "Delimiter to put between values"
            ] #[none]] 
        ctx||348~escape-value [function! 2 [
                {Escape quotes and when required, enclose value in quotes} 
                value [any-type!] "Value to escape (is formed)" 
                delimiter [char! string!] "Delimiter character to be escaped" 
                /local quot? len
            ] #[none]] 
        ctx||348~next-column-name [function! 1 [
                "Return name of next column (A->B, Z->AA, ...)" 
                name [char! string!] "Name of current column" 
                /local length index position previous
            ] #[none]] 
        ctx||348~make-header [function! 1 [
                "Return default header (A-Z, AA-ZZ, ...)" 
                length [integer!] "Required length of header" 
                /local key
            ] #[none]] 
        ctx||348~get-columns [function! 1 [
                "Return all keywords from maps or objects" 
                data [block!] "Data must block of maps or objects" 
                /local columns
            ] #[none]] 
        ctx||348~encode-map [function! 2 [
                "Make CSV string from map! of columns" 
                data [map!] "Map of columns" 
                delimiter [char! string!] "Delimiter to use in CSV string" 
                /local output keys length key index line
            ] #[none]] 
        ctx||348~encode-maps [function! 2 [
                "Make CSV string from block of maps/objects" 
                data [block!] "Block of maps/objects" 
                delimiter [char! string!] "Delimiter to use in CSV string" 
                /local columns value line column
            ] #[none]] 
        ctx||348~encode-flat [function! 3 [
                "Convert block of fixed size records to CSV string" 
                data [block!] "Block treated as fixed size records" 
                delimiter [char! string!] "Delimiter to use in CSV string" 
                size [integer!] "Size of record"
            ] #[none]] 
        ctx||348~encode-blocks [function! 2 [
                "Convert block of records to CSV string" 
                data [block!] "Block of blocks, each block is one record" 
                delimiter [char! string!] "Delimiter to use in CSV string" 
                /local length line csv-line
            ] #[none]] 
        load-csv [function! 1 [
                {Converts CSV text to a block of rows, where each row is a block of fields.} 
                data [string!] "Text CSV data to load" 
                /with 
                delimiter [char! string!] "Delimiter to use (default is comma)" 
                /header {Treat first line as header; implies /as-columns if /as-records is not used} 
                /as-columns {Returns named columns; default names if /header is not used} 
                /as-records "Returns records instead of rows; implies /header" 
                /flat {Returns a flat block; you need to know the number of fields} 
                /trim "Ignore spaces between quotes and delimiter" 
                /quote 
                qt-char [char!] {Use different character for quotes than double quote (")} 
                /local disallowed refs output out-map longest line value newline quotchars valchars quoted-value char normal-value s e single-value values add-value add-line length index line-rule init parsed? mark key-index key
            ] [
                /with 1 1 
                /header 2 0 
                /as-columns 3 0 
                /as-records 4 0 
                /flat 5 0 
                /trim 6 0 
                /quote 7 1
            ] ctx||348] 
        to-csv [function! 1 [
                "Make CSV data from input value" 
                data [block! map! object!] {May be block of fixed size records, block of block records, or map columns} 
                /with "Delimiter to use (default is comma)" 
                delimiter [char! string!] 
                /skip "Treat block as table of records with fixed length" 
                size [integer!] 
                /quote 
                qt-char [char!] {Use different character for quotes than double quote (")} 
                /local longest keyval? types value
            ] [
                /with 1 1 
                /skip 2 1 
                /quote 3 1
            ] ctx||348] 
        ctx||362~encode [routine! 2 [data #[block![2 576x1 red/cell!]3] where #[block![2 576x1 red/cell!]3]] #[none]] 
        ctx||362~decode [routine! 1 [
                payload #[block![2 576x1 red/cell!]3] 
                /local 
                blk #[block![2 576x1 red-block!]3] 
                bin #[block![2 576x1 red-binary!]3]
            ] #[none]] 
        ctx||365~on-change* [function! 3 [word old new 
                /local srs
            ] #[none]] 
        ctx||368~on-change* [function! 3 [word old new 
                /local srs
            ] #[none]] 
        ctx||368~on-deep-change* [function! 7 [owner word target action new index part] #[none]] 
        reactor [function! 1 [spec [block!]] #[none]] 
        deep-reactor [function! 1 [spec [block!]] #[none]] 
        ctx||373~add-relation [function! 4 [
                obj [object!] 
                word 
                reaction [block! function!] 
                targets [block! none! object! set-word!] 
                /local new-rel
            ] #[none]] 
        ctx||373~eval [function! 1 [code [block!] /safe 
                /local result
            ] [/safe 1 0]] 
        ctx||373~eval-reaction [function! 3 [reactor [object!] reaction [block! function!] target /mark] [/mark 1 0]] 
        ctx||373~pending? [function! 2 [reactor [object!] reaction [block! function!] 
                /local q
            ] #[none]] 
        ctx||373~check [function! 1 [reactor [object!] /only field [set-word! word!] 
                /local pos reaction q q'
            ] [/only 1 1]] 
        stop-reactor [function! 1 [
                face [object!] 
                /deep 
                /local list pos f
            ] [
                /deep 1 0
            ] ctx||373] 
        clear-reactions [function! 0 ["Removes all reactive relations"] #[none] ctx||373] 
        dump-reactions [function! 0 [
                {Output all the current reactive relations for debugging purpose} 
                /local limit count obj field reaction target list
            ] #[none] ctx||373] 
        ctx||373~is~ [function! 2 [
                {Defines a reactive relation whose result is assigned to a word} 
                'field [set-word!] {Set-word which will get set to the result of the reaction} 
                reaction [block!] "Reactive relation" 
                /local obj rule item
            ] #[none] ctx||373] 
        is [op! 2 [
                {Defines a reactive relation whose result is assigned to a word} 
                'field [set-word!] {Set-word which will get set to the result of the reaction} 
                reaction [block!] "Reactive relation" 
                /local obj rule item
            ] #[none]] 
        react? [function! 2 [
                {Returns a reactive relation if an object's field is a reactive source} 
                reactor [object!] "Object to check" 
                field [word!] "Field to check" 
                /target "Check if it's a target instead of a source" 
                return: [block! function! word! none!] "Returns reaction, type or NONE" 
                /local pos
            ] [
                /target 1 0
            ] ctx||373] 
        react [function! 1 [
                {Defines a new reactive relation between two or more objects} 
                reaction [block! function!] "Reactive relation" 
                /link "Link objects together using a reactive relation" 
                objects [block!] "Objects to link together" 
                /unlink "Removes an existing reactive relation" 
                src [block! object! word!] "'all word, or a reactor or a list of reactors" 
                /later "Run the reaction on next change instead of now" 
                /with "Specifies an optional face object (internal use)" 
                ctx [none! object! set-word!] "Optional context for VID faces or target set-word" 
                return: [block! function! none!] {The reactive relation or NONE if no relation was processed} 
                /local objs found? rule item pos obj saved part path
            ] [
                /link 1 1 
                /unlink 2 1 
                /later 3 0 
                /with 4 1
            ] ctx||373] 
        register-scheme [function! 1 [
                "Registers a new scheme" 
                spec [object!] "Scheme definition" 
                /native 
                dispatch [handle!]
            ] [
                /native 1 1
            ]] 
        ctx||388~alpha-num+ [function! 1 [more [string!]] #[none]] 
        ctx||388~parse-url [function! 1 [
                {Return object with URL components, or cause an error if not a valid URL} 
                url [string! url!] 
                /throw-error "Throw an error, instead of returning NONE." 
                /local scheme user-info host port path target query fragment ref
            ] [
                /throw-error 1 0
            ]] 
        decode-url [function! 1 [
                {Decode a URL into an object containing its constituent parts} 
                url [string! url!]
            ] #[none] ctx||388] 
        encode-url [function! 1 [url-obj [object!] "What you'd get from decode-url" 
                /local result
            ] #[none] ctx||388] 
        ctx||394~do-quit [function! 0 [] #[none]] 
        ctx||394~throw-error [function! 3 [error [error!] cmd [issue!] code [block!] /local w] #[none]] 
        ctx||394~syntax-error [function! 2 [s [block! paren!] e [block! paren!]] #[none]] 
        ctx||394~do-safe [function! 1 [code [block! paren!] /manual /with cmd [issue!] /local res t? src] [/manual 1 0 /with 2 1]] 
        ctx||394~do-code [function! 2 [code [block! paren!] cmd [issue!] /local p] #[none]] 
        ctx||394~count-args [function! 1 [spec [block!] /block /local total pos] [/block 1 0]] 
        ctx||394~arg-mode? [function! 2 [spec [block!] idx [integer!]] #[none]] 
        ctx||394~func-arity? [function! 1 [spec [block!] /with path [path!] /block /local arity pos] [/with 1 1 /block 2 0]] 
        ctx||394~value-path? [function! 1 [path [path!] /local value i item selectable] #[none]] 
        ctx||394~fetch-next [function! 1 [code [block! paren!] /local i left item item2 value fn-spec path f-arity at-op? op-mode] #[none]] 
        ctx||394~eval [function! 2 [code [block! paren!] cmd [issue!] /local after expr] #[none]] 
        ctx||394~do-macro [function! 3 [name pos [block! paren!] arity [integer!] /local cmd saved p v res] #[none]] 
        ctx||394~register-macro [function! 1 [spec [block!] /local cnt rule p name macro pos valid? named?] #[none]] 
        ctx||394~reset [function! 1 [job [none! object!]] #[none]] 
        ctx||394~expand [function! 2 [
                code [block! paren!] job [none! object!] 
                /clean 
                /local rule e pos cond value then else cases body keep? expr src saved file
            ] [
                /clean 1 0
            ]] 
        expand-directives [function! 1 [
                {Invokes the preprocessor on argument list, modifying and returning it} 
                code [block! paren!] "List of Red values to preprocess" 
                /clean "Clear all previously created macros and words" 
                /local job
            ] [
                /clean 1 0
            ] ctx||394] 
        hex-to-rgb [function! 1 [
                {Converts a color in hex format to a tuple value; returns NONE if it fails} 
                hex [issue!] "Accepts #rgb, #rrggbb, #rrggbbaa" 
                return: [tuple! none!] 
                /local str bin
            ] #[none]] 
        within? [function! 3 [
                {Return TRUE if the point is within the rectangle bounds} 
                point [pair!] "XY position" 
                offset [pair!] "Offset of area" 
                size [pair!] "Size of area" 
                return: [logic!]
            ] #[none]] 
        overlap? [function! 2 [
                {Return TRUE if the two faces bounding boxes are overlapping} 
                A [object!] "First face" 
                B [object!] "Second face" 
                return: [logic!] "TRUE if overlapping" 
                /local A1 B1 A2 B2
            ] #[none]] 
        distance? [function! 2 [
                {Returns the distance between the center of two faces} 
                A [object!] "First face" 
                B [object!] "Second face" 
                return: [float!] "Distance between them"
            ] #[none]] 
        event? [routine! 1 [value #[block![2 206x1 red/cell!]3] return: #[block![2 206x1 logic!]3]] #[none]] 
        face? [function! 1 [
                value 
                return: [logic!]
            ] #[none]] 
        size-text [function! 1 [
                face [object!] 
                /with 
                text [string!] 
                return: [pair! none!]
            ] [
                /with 1 1
            ]] 
        caret-to-offset [function! 2 [
                face [object!] 
                pos [integer!] 
                /lower 
                return: [pair!] 
                /local opt
            ] [
                /lower 1 0
            ]] 
        offset-to-caret [function! 2 [
                face [object!] 
                pt [pair!] 
                return: [integer!]
            ] #[none]] 
        offset-to-char [function! 2 [
                face [object!] 
                pt [pair!] 
                return: [integer!]
            ] #[none]] 
        ctx||430~tail-idx? [function! 0 [] #[none]] 
        ctx||430~push-color [function! 1 [c [tuple!]] #[none]] 
        ctx||430~pop-color [function! 0 [/local entry pos] #[none]] 
        ctx||430~close-colors [function! 0 [/local pos] #[none]] 
        ctx||430~push [function! 1 [style [block! word!]] #[none]] 
        ctx||430~pop [function! 1 [style [word!] 
                /local entry type
            ] #[none]] 
        ctx||430~pop-all [function! 1 [mark [block!] 
                /local first? i
            ] #[none]] 
        ctx||430~optimize [function! 0 [
                /local cur pos range pos1 e s l mov
            ] #[none]] 
        rtd-layout [function! 1 [
                "Returns a rich-text face from a RTD source code" 
                spec [block!] "RTD source code" 
                /only "Returns only [text data] facets" 
                /with "Populate an existing face object" 
                face [object!] "Face object to populate" 
                return: [object! block!]
            ] [
                /only 1 0 
                /with 2 1
            ] ctx||430] 
        ctx||428~line-height? [function! 2 [
                face [object!] 
                pos [integer!] 
                return: [integer!]
            ] #[none]] 
        ctx||428~line-count? [function! 1 [
                face [object!] 
                return: [integer!]
            ] #[none]] 
        metrics? [function! 2 [
                face [object!] 
                type [word!] 
                /total 
                axis [word!] 
                /local res
            ] [
                /total 1 1
            ]] 
        set-flag [function! 3 [
                face [object!] 
                facet [word!] 
                value [any-type!] 
                /local flags
            ] #[none]] 
        find-flag? [routine! 2 [
                facet #[block![2 206x1 red/cell!]3] 
                flag #[block![2 206x1 red-word!]3] 
                /local 
                word #[block![2 206x1 red-word!]3] 
                value #[block![2 206x1 red/cell!]3] 
                tail #[block![2 206x1 red/cell!]3] 
                bool #[block![2 206x1 red-logic!]3] 
                type #[block![2 206x1 integer!]3] 
                found? #[block![2 206x1 logic!]3]
            ] #[none]] 
        debug-info? [function! 1 [face [object!] return: [logic!]] #[none]] 
        on-face-deep-change* [function! 9 [owner word target action new index part state forced? 
                /local faces face modal? pane
            ] #[none]] 
        link-tabs-to-parent [function! 1 [
                face [object!] 
                /init 
                /local faces visible?
            ] [
                /init 1 0
            ]] 
        link-sub-to-parent [function! 4 [face [object!] type [word!] old new 
                /local parent
            ] #[none]] 
        update-font-faces [function! 1 [parent [block! none!] 
                /local f
            ] #[none]] 
        ctx||450~on-change* [function! 3 [word old new 
                /local srs same-pane? f saved
            ] #[none]] 
        ctx||450~on-deep-change* [function! 7 [owner word target action new index part] #[none]] 
        ctx||454~on-change* [function! 3 [word old new] #[none]] 
        ctx||454~on-deep-change* [function! 7 [owner word target action new index part] #[none]] 
        ctx||458~on-change* [function! 3 [word old new 
                /local f
            ] #[none]] 
        ctx||461~on-change* [function! 3 [word old new] #[none]] 
        ctx||464~capture-events [function! 2 [face [object!] event [event!] /local result] #[none]] 
        ctx||464~awake [function! 1 [event [event!] /with face /local result 
                handler
            ] [/with 1 1]] 
        ctx||473~make-null-handle [routine! 0 [] #[none]] 
        ctx||473~get-screen-size [routine! 1 [
                id #[block![2 2514x1 integer!]3] 
                /local 
                pair #[block![2 2514x1 red-pair!]3]
            ] #[none]] 
        ctx||473~size-text [routine! 2 [
                face #[block![2 2514x1 red-object!]3] 
                value #[block![2 2514x1 red/cell!]3] 
                /local 
                values #[block![2 2514x1 red/cell!]3] 
                text #[block![2 2514x1 red-string!]3] 
                pair #[block![2 2514x1 red-pair!]3]
            ] #[none]] 
        ctx||473~on-change-facet [routine! 7 [
                owner #[block![2 2514x1 red-object!]3] 
                word #[block![2 2514x1 red-word!]3] 
                value #[block![2 2514x1 red/cell!]3] 
                action #[block![2 2514x1 red-word!]3] 
                new #[block![2 2514x1 red/cell!]3] 
                index #[block![2 2514x1 integer!]3] 
                part #[block![2 2514x1 integer!]3]
            ] #[none]] 
        ctx||473~update-font [routine! 2 [font #[block![2 2514x1 red-object!]3] flags #[block![2 2514x1 integer!]3]] #[none]] 
        ctx||473~update-para [routine! 2 [face #[block![2 2514x1 red-object!]3] flags #[block![2 2514x1 integer!]3]] #[none]] 
        ctx||473~destroy-view [routine! 2 [face #[block![2 2514x1 red-object!]3] empty? #[block![2 2514x1 logic!]3]] #[none]] 
        ctx||473~update-view [routine! 1 [face #[block![2 2514x1 red-object!]3]] #[none]] 
        ctx||473~refresh-window [routine! 1 [h #[block![2 2514x1 red-handle!]3]] #[none]] 
        ctx||473~redraw [routine! 1 [face #[block![2 2514x1 red-object!]3] /local h #[block![2 2514x1 integer!]3]] #[none]] 
        ctx||473~show-window [routine! 1 [id #[block![2 2514x1 red-handle!]3]] #[none]] 
        ctx||473~make-view [routine! 2 [face #[block![2 2514x1 red-object!]3] parent #[block![2 2514x1 red-handle!]3]] #[none]] 
        ctx||473~draw-image [routine! 2 [image #[block![2 2514x1 red-image!]3] cmds #[block![2 2514x1 red-block!]3]] #[none]] 
        ctx||473~draw-face [routine! 2 [face #[block![2 2514x1 red-object!]3] cmds #[block![2 2514x1 red-block!]3] /local int #[block![2 2514x1 red-integer!]3]] #[none]] 
        ctx||473~do-event-loop [routine! 1 [no-wait? #[block![2 2514x1 logic!]3] /local bool #[block![2 2514x1 red-logic!]3]] #[none]] 
        ctx||473~exit-event-loop [routine! 0 [] #[none]] 
        ctx||473~request-font [routine! 3 [font #[block![2 2514x1 red-object!]3] selected #[block![2 2514x1 red-object!]3] mono? #[block![2 2514x1 logic!]3]] #[none]] 
        ctx||473~request-file [routine! 5 [
                title #[block![2 2514x1 red-string!]3] 
                name #[block![2 2514x1 red-file!]3] 
                filter #[block![2 2514x1 red-block!]3] 
                save? #[block![2 2514x1 logic!]3] 
                multi? #[block![2 2514x1 logic!]3]
            ] #[none]] 
        ctx||473~request-dir [routine! 5 [
                title #[block![2 2514x1 red-string!]3] 
                dir #[block![2 2514x1 red-file!]3] 
                filter #[block![2 2514x1 red-block!]3] 
                keep? #[block![2 2514x1 logic!]3] 
                multi? #[block![2 2514x1 logic!]3]
            ] #[none]] 
        ctx||473~text-box-metrics [routine! 3 [
                box #[block![2 2514x1 red-object!]3] 
                arg0 #[block![2 2514x1 red/cell!]3] 
                type #[block![2 2514x1 integer!]3] 
                /local 
                state #[block![2 2514x1 red-block!]3] 
                bool #[block![2 2514x1 red-logic!]3] 
                layout? #[block![2 2514x1 logic!]3]
            ] #[none]] 
        ctx||473~update-scroller [routine! 2 [scroller #[block![2 2514x1 red-object!]3] flags #[block![2 2514x1 integer!]3]] #[none]] 
        ctx||473~init [function! 0 [/local svs colors fonts] #[none]] 
        draw [function! 2 [
                "Draws scalable vector graphics to an image" 
                image [image! pair!] "Image or size for an image" 
                cmd [block!] "Draw commands" 
                /transparent "Make a transparent image, if pair! spec is used" 
                return: [image!]
            ] [
                /transparent 1 0
            ]] 
        ctx||483~title-ize [function! 1 [text [string!] return: [string!] 
                /local p
            ] #[none]] 
        ctx||483~sentence-ize [function! 1 [text [string!] return: [string!] 
                /local h s e
            ] #[none]] 
        ctx||483~capitalize [function! 1 [
                {Capitalize widget text according to macOS guidelines} 
                root [object!] 
                /local rule pos
            ] #[none]] 
        ctx||483~adjust-buttons [function! 1 [
                {Use standard button classes when buttons are narrow enough} 
                root [object!] 
                /local def-margins def-margin-yy opts class svmm y align axis marg def-marg
            ] #[none]] 
        ctx||483~Cancel-OK [function! 1 [
                "Put OK buttons last" 
                root [object!] 
                /local pos-x last-but pos-y f
            ] #[none]] 
        ctx||481~process [function! 1 [root [object!] 
                /local list name
            ] #[none]] 
        ctx||479~throw-error [function! 1 [spec [block!]] #[none]] 
        ctx||479~process-reactors [function! 1 [reactors [block!] /local res 
                f blk later? ctx face
            ] #[none]] 
        ctx||479~calc-size [function! 1 [face [object!] 
                /local min-sz data txt s len mark e new
            ] #[none]] 
        ctx||479~align-faces [function! 4 [pane [block!] dir [word!] align [word!] max-sz [integer!] 
                /local edge? top-left? axis svmm face offset mar type
            ] #[none]] 
        ctx||479~resize-child-panels [function! 1 [tab [object!] 
                /local tp-size pad pane
            ] #[none]] 
        ctx||479~clean-style [function! 2 [tmpl [block!] type [word!] /local para font] #[none]] 
        ctx||479~process-draw [function! 1 [code [block!] 
                /local rule pos color
            ] #[none]] 
        ctx||479~pre-load [function! 1 [value 
                /local color
            ] #[none]] 
        ctx||479~add-option [function! 2 [opts [object!] spec [block!] 
                /local field value
            ] #[none]] 
        ctx||479~add-flag [function! 4 [obj [object!] facet [word!] field [word!] flag return: [logic!] 
                /local blk
            ] #[none]] 
        ctx||479~fetch-value [function! 1 [blk 
                /local value
            ] #[none]] 
        ctx||479~fetch-argument [function! 2 [expected [datatype! typeset!] 'pos [word!] 
                /local spec type value
            ] #[none]] 
        ctx||479~fetch-expr [function! 1 [code [word!]] #[none]] 
        ctx||479~fetch-options [function! 7 [
                face [object!] opts [object!] style [block!] spec [block!] css [block!] reactors [block!] styling? [logic!] 
                /no-skip 
                return: [block!] 
                /local opt? divides calc-y? do-with obj-spec! rate! color! cursor! value match? drag-on default hint cursor tight? later? max-sz p words user-size? oi x font face-font field actors name f s b pad sz min-sz mar
            ] [
                /no-skip 1 0
            ]] 
        ctx||479~make-actor [function! 4 [obj [object!] name [word!] body spec [block!]] #[none]] 
        layout [function! 1 [
                {Return a face with a pane built from a VID description} 
                spec [block!] "Dialect block of styles, attributes, and layouts" 
                /tight "Zero offset and origin" 
                /options 
                user-opts [block!] "Optional features in [name: value] format" 
                /flags 
                flgs [block! word!] "One or more window flags" 
                /only "Returns only the pane block" 
                /parent 
                panel [object!] 
                divides [integer! none!] 
                /styles "Use an existing styles list" 
                css [block!] "Styles list" 
                /local axis anti 
                background! list reactors local-styles pane-size direction align begin size max-sz current global? below? top-left bound cursor origin spacing opts opt-words re-align sz words reset focal-face svmp pad value anti2 at-offset later? name styling? style styled? st actors face h pos styled w blk vid-align mar divide? index dir pad2 image
            ] [
                /tight 1 0 
                /options 2 1 
                /flags 3 1 
                /only 4 0 
                /parent 5 2 
                /styles 6 1
            ] ctx||479] 
        do-events [function! 0 [
                /no-wait 
                return: [logic! word!] 
                /local result 
                win
            ] [
                /no-wait 1 0
            ]] 
        stop-events [function! 0 [] #[none]] 
        do-safe [function! 1 [code [block!] /local result] #[none]] 
        do-actor [function! 3 [face [object!] event [event! none!] type [word!] /local result 
                act name
            ] #[none]] 
        show [function! 1 [
                face [block! object!] 
                /with 
                parent [object!] 
                /force 
                return: [logic!] 
                /local show? f pending owner word target action new index part state new? p obj field pane
            ] [
                /with 1 1 
                /force 2 0
            ]] 
        unview [function! 0 [
                /all 
                /only 
                face [object!] 
                /local all? svs pane
            ] [
                /all 1 0 
                /only 2 1
            ]] 
        view [function! 1 [
                spec [block! object!] 
                /tight 
                /options 
                opts [block!] 
                /flags 
                flgs [block! word!] 
                /no-wait
            ] [
                /tight 1 0 
                /options 2 1 
                /flags 3 1 
                /no-wait 4 0
            ]] 
        center-face [function! 1 [
                face [object!] 
                /x 
                /y 
                /with 
                parent [object!] 
                return: [object!] 
                /local pos
            ] [
                /x 1 0 
                /y 2 0 
                /with 3 1
            ]] 
        make-face [function! 1 [
                style [word!] 
                /spec 
                blk [block!] 
                /offset 
                xy [pair!] 
                /size 
                wh [pair!] 
                /local 
                svv face styles model opts css
            ] [
                /spec 1 1 
                /offset 2 1 
                /size 3 1
            ]] 
        dump-face [function! 1 [
                face [object!] 
                /local depth f
            ] #[none]] 
        get-scroller [function! 2 [
                face [object!] 
                orientation [word!] 
                return: [object!] 
                /local position page min-size max-size parent vertical?
            ] #[none]] 
        insert-event-func [function! 1 [
                fun [block! function!]
            ] #[none]] 
        remove-event-func [function! 1 [
                fun [function!]
            ] #[none]] 
        request-font [function! 0 [
                /font 
                ft [object!] 
                /mono
            ] [
                /font 1 1 
                /mono 2 0
            ]] 
        request-file [function! 0 [
                /title 
                text [string!] 
                /file 
                name [file! string!] 
                /filter 
                list [block!] 
                /save 
                /multi
            ] [
                /title 1 1 
                /file 2 1 
                /filter 3 1 
                /save 4 0 
                /multi 5 0
            ]] 
        request-dir [function! 0 [
                /title 
                text [string!] 
                /dir 
                name [file! string!] 
                /filter 
                list [block!] 
                /keep 
                /multi
            ] [
                /title 1 1 
                /dir 2 1 
                /filter 3 1 
                /keep 4 0 
                /multi 5 0
            ]] 
        set-focus [function! 1 [
                face [object!] 
                /local p
            ] #[none]] 
        foreach-face [function! 2 [
                face [object!] 
                body [block! function!] 
                /with 
                spec [block! none!] 
                /post 
                /sub post? 
                /local exec
            ] [
                /with 1 1 
                /post 2 0 
                /sub 3 1
            ]] 
        keep [function! 1 [v /only] [/only 1 0]] 
        all? [intrinsic! 1 [{Evaluates and returns the last value if all are truthy; else NONE} conds [block!]] #[none]]
    ] 1825 #[hash![datatype! unset! 
        make unset! none! unset! logic! unset! block! unset! string! unset! integer! unset! word! unset! error! unset! typeset! unset! file! unset! url! unset! set-word! unset! get-word! unset! lit-word! unset! refinement! unset! binary! unset! paren! unset! char! unset! issue! unset! path! unset! set-path! unset! get-path! unset! lit-path! unset! native! unset! action! unset! op! unset! function! unset! routine! unset! object! unset! bitset! unset! float! unset! point! unset! vector! unset! map! unset! hash! unset! pair! unset! percent! unset! tuple! unset! image! unset! time! unset! tag! unset! email! unset! handle! unset! date! unset! port! unset! money! unset! ref! unset! event! unset! none unset! true unset! false unset! random unset! reflect unset! to unset! form unset! mold unset! modify unset! absolute unset! add unset! divide unset! multiply unset! negate unset! power unset! remainder unset! round unset! subtract unset! even? unset! odd? unset! and~ unset! complement unset! or~ unset! xor~ unset! append unset! at unset! back unset! change unset! clear unset! copy unset! find unset! head unset! head? unset! index? unset! insert unset! length? unset! move unset! next unset! pick unset! poke unset! put unset! remove unset! reverse unset! select unset! sort unset! skip unset! swap unset! tail unset! tail? unset! take unset! trim unset! create unset! close unset! delete unset! open unset! open? unset! query unset! read unset! rename unset! update unset! write unset! if unset! unless unset! either unset! any unset! all unset! while unset! until unset! loop unset! repeat unset! forever unset! foreach unset! forall unset! remove-each unset! func unset! function unset! does unset! has unset! switch unset! case unset! do unset! reduce unset! compose unset! get unset! set unset! print unset! prin unset! equal? unset! not-equal? unset! strict-equal? unset! lesser? unset! greater? unset! lesser-or-equal? unset! greater-or-equal? unset! same? unset! not unset! type? unset! stats unset! bind unset! in unset! parse unset! union unset! unique unset! intersect unset! difference unset! exclude unset! complement? unset! dehex unset! enhex unset! negative? unset! positive? unset! max unset! min unset! shift unset! to-hex unset! sine unset! cosine unset! tangent unset! arcsine unset! arccosine unset! arctangent unset! arctangent2 unset! NaN? unset! zero? unset! log-2 unset! log-10 unset! log-e unset! exp unset! square-root unset! construct unset! value? unset! try unset! uppercase unset! lowercase unset! as-pair unset! as-money unset! break unset! continue unset! exit unset! return unset! throw unset! catch unset! extend unset! debase unset! enbase unset! to-local-file unset! wait unset! checksum unset! unset unset! new-line unset! new-line? unset! context? unset! set-env unset! get-env unset! list-env unset! now unset! sign? unset! as unset! call unset! size? unset! browse unset! compress unset! decompress unset! recycle unset! transcode unset! quit-return unset! set-quiet unset! set-slot-quiet unset! shift-right unset! shift-left unset! shift-logical unset! last-lf? unset! get-current-dir unset! set-current-dir unset! create-dir unset! exists? unset! os-info unset! as-color unset! as-ipv4 unset! as-rgba unset! count-chars unset! read-clipboard unset! write-clipboard unset! write-stdout unset! yes unset! on unset! no unset! off unset! tab unset! cr unset! newline unset! lf unset! escape unset! slash unset! sp unset! space unset! null unset! crlf unset! dot unset! comma unset! dbl-quote unset! pi unset! Rebol unset! internal! unset! external! unset! number! unset! scalar! unset! any-word! unset! all-word! unset! any-list! unset! any-path! unset! any-block! unset! any-function! unset! any-object! unset! any-string! unset! series! unset! immediate! unset! default! unset! any-type! unset! aqua unset! beige unset! black unset! blue unset! brick unset! brown unset! coal unset! coffee unset! crimson unset! cyan unset! forest unset! gold unset! gray unset! green unset! ivory unset! khaki unset! leaf unset! linen unset! magenta unset! maroon unset! mint unset! navy unset! oldrab unset! olive unset! orange unset! papaya unset! pewter unset! pink unset! purple unset! reblue unset! rebolor unset! red unset! sienna unset! silver unset! sky unset! snow unset! tanned unset! teal unset! violet unset! water unset! wheat unset! white unset! yello unset! yellow unset! glass unset! transparent unset! routine unset! alert unset! also unset! attempt unset! comment unset! quit unset! empty? unset! ?? unset! probe unset! quote unset! first unset! second unset! third unset! fourth unset! fifth unset! last unset! spec-of unset! body-of unset! words-of unset! class-of unset! values-of unset! bitset? unset! binary? unset! block? unset! char? unset! email? unset! file? unset! float? unset! get-path? unset! get-word? unset! hash? unset! integer? unset! issue? unset! lit-path? unset! lit-word? unset! logic? unset! map? unset! none? unset! pair? unset! paren? unset! path? unset! percent? unset! refinement? unset! set-path? unset! set-word? unset! string? unset! tag? unset! time? unset! typeset? unset! tuple? unset! unset? unset! url? unset! word? unset! image? unset! date? unset! money? unset! ref? unset! handle? unset! error? unset! action? unset! native? unset! datatype? unset! function? unset! object? unset! op? unset! routine? unset! vector? unset! any-list? unset! any-block? unset! any-function? unset! any-object? unset! any-path? unset! any-string? unset! any-word? unset! series? unset! number? unset! immediate? unset! scalar? unset! all-word? unset! to-bitset unset! to-binary unset! to-block unset! to-char unset! to-email unset! to-file unset! to-float unset! to-get-path unset! to-get-word unset! to-hash unset! to-integer unset! to-issue unset! to-lit-path unset! to-lit-word unset! to-logic unset! to-map unset! to-none unset! to-pair unset! to-paren unset! to-path unset! to-percent unset! to-refinement unset! to-set-path unset! to-set-word unset! to-string unset! to-tag unset! to-time unset! to-typeset unset! to-tuple unset! to-unset unset! to-url unset! to-word unset! to-image unset! to-date unset! to-money unset! to-ref unset! context unset! alter unset! offset? unset! repend unset! replace unset! math unset! charset unset! p-indent unset! on-parse-event unset! parse-trace unset! suffix? unset! scan unset! load unset! save unset! cause-error unset! pad unset! mod unset! modulo unset! eval-set-path unset! to-red-file unset! dir? unset! normalize-dir unset! what-dir unset! change-dir unset! make-dir unset! extract unset! extract-boot-args unset! collect unset! flip-exe-flag unset! split unset! dirize unset! clean-path unset! split-path unset! do-file unset! path-thru unset! exists-thru? unset! read-thru unset! load-thru unset! do-thru unset! cos unset! sin unset! tan unset! acos unset! asin unset! atan unset! atan2 unset! sqrt unset! to-UTC-date unset! to-local-date unset! transcode-trace unset! rejoin unset! sum unset! average unset! last? unset! dt unset! single? unset! keys-of unset! object unset! halt unset! system unset! version unset! build unset! date unset! git unset! branch unset! tag unset! ahead unset! commit unset! message unset! config unset! config-name unset! OS unset! OS-version unset! ABI unset! link? unset! debug? unset! encap? unset! build-prefix unset! build-basename unset! build-suffix unset! format unset! type unset! target unset! cpu-version unset! verbosity unset! sub-system unset! runtime? unset! use-natives? unset! debug-safe? unset! dev-mode? unset! need-main? unset! PIC? unset! base-address unset! dynamic-linker unset! syscall unset! export-ABI unset! stack-align-16? unset! literal-pool? unset! unicode? unset! red-pass? unset! red-only? unset! red-store-bodies? unset! red-strict-check? unset! red-tracing? unset! red-help? unset! redbin-compress? unset! legacy unset! gui-console? unset! libRed? unset! libRedRT? unset! libRedRT-update? unset! GUI-engine unset! modules unset! show unset! command-line unset! show-func-map? unset! words unset! platform unset! catalog unset! datatypes unset! actions unset! natives unset! accessors unset! errors unset! code unset! while-cond unset! note unset! no-load unset! syntax unset! invalid unset! missing unset! no-header unset! no-rs-header unset! bad-header unset! malconstruct unset! bad-char unset! script unset! no-value unset! need-value unset! not-defined unset! not-in-context unset! no-arg unset! expect-arg unset! expect-val unset! expect-type unset! cannot-use unset! invalid-arg unset! invalid-type unset! invalid-type-spec unset! invalid-op unset! no-op-arg unset! bad-op-spec unset! invalid-data unset! invalid-part unset! not-same-type unset! not-same-class unset! not-related unset! bad-func-def unset! bad-func-arg unset! bad-func-extern unset! no-refine unset! bad-refines unset! bad-refine unset! word-first unset! empty-path unset! invalid-path unset! invalid-path-set unset! invalid-path-get unset! bad-path-type unset! bad-path-set unset! bad-field-set unset! dup-vars unset! past-end unset! missing-arg unset! out-of-range unset! invalid-chars unset! invalid-compare unset! wrong-type unset! invalid-refine-arg unset! type-limit unset! size-limit unset! no-return unset! throw-usage unset! locked-word unset! protected unset! bad-bad unset! bad-make-arg unset! bad-to-arg unset! invalid-months unset! invalid-spec-field unset! missing-spec-field unset! move-bad unset! too-long unset! invalid-char unset! bad-loop-series unset! wrong-denom unset! bad-denom unset! invalid-obj-evt unset! parse-rule unset! parse-end unset! parse-invalid-ref unset! parse-block unset! parse-unsupported unset! parse-infinite unset! parse-stack unset! parse-keep unset! parse-into-bad unset! parse-into-type unset! invalid-draw unset! invalid-data-facet unset! face-type unset! not-window unset! bad-window unset! not-linked unset! not-event-type unset! invalid-facet-type unset! vid-invalid-syntax unset! rtd-invalid-syntax unset! rtd-no-match unset! react-bad-func unset! react-not-enough unset! react-no-match unset! react-bad-obj unset! react-gctx unset! lib-invalid-arg unset! buffer-not-enough unset! zero-divide unset! overflow unset! positive unset! access unset! cannot-open unset! cannot-close unset! invalid-utf8 unset! not-open unset! no-connect unset! no-scheme unset! unknown-scheme unset! invalid-spec unset! invalid-port unset! invalid-actor unset! no-port-action unset! no-create unset! no-codec unset! bad-media unset! invalid-cmd unset! reserved1 unset! reserved2 unset! user unset! internal unset! bad-path unset! not-here unset! no-memory unset! wrong-mem unset! stack-overflow unset! limit-hit unset! too-deep unset! no-cycle unset! feature-na unset! not-done unset! invalid-error unset! routines unset! red-system unset! state unset! interpreted? unset! last-error unset! trace unset! codecs unset! schemes unset! ports unset! locale unset! language unset! language* unset! locale* unset! months unset! days unset! currencies unset! list unset! on-change* unset! on-deep-change* unset! options unset! boot unset! home unset! path unset! cache unset! thru-cache unset! args unset! do-arg unset! debug unset! secure unset! quiet unset! binary-base unset! decimal-digits unset! money-digits unset! module-paths unset! file-types unset! float unset! pretty? unset! full? unset! title unset! header unset! parent unset! standard unset! name unset! file unset! author unset! needs unset! port unset! spec unset! scheme unset! actor unset! awake unset! data unset! extra unset! error unset! id unset! arg1 unset! arg2 unset! arg3 unset! near unset! where unset! stack unset! file-info unset! size unset! url-parts unset! user-info unset! host unset! fragment unset! ref unset! info unset! lexer unset! pre-load unset! exit-states unset! tracer unset! lex unset! console unset! view unset! reactivity unset! + unset! - unset! * unset! / unset! // unset! %"" unset! = unset! <> unset! == unset! =? unset! < unset! > unset! <= unset! >= unset! << unset! >> unset! ">>>" unset! ** unset! and unset! or unset! xor unset! mime-type unset! suffixes unset! encode unset! ctx||294~encode unset! decode unset! ctx||294~decode unset! ctx||298~encode unset! ctx||298~decode unset! ctx||302~encode unset! ctx||302~decode unset! ctx||306~encode unset! ctx||306~decode unset! BOM unset! BOM-UTF-16? unset! BOM-UTF-32? unset! enquote unset! high-surrogate? unset! low-surrogate? unset! translit unset! json-to-red-escape-table unset! red-to-json-escape-table unset! json-esc-ch unset! json-escaped unset! red-esc-ch unset! decode-backslash-escapes unset! encode-backslash-escapes unset! ctrl-char unset! ws unset! ws* unset! ws+ unset! sep unset! digit unset! non-zero-digit unset! hex-char unset! chars unset! not-word-char unset! word-1st unset! word-char unset! sign unset! int unset! frac unset! number unset! numeric-literal unset! string-literal unset! decode-unicode-char unset! replace-unicode-escapes unset! json-object unset! property-list unset! property unset! json-name unset! array-list unset! json-array unset! json-value unset! push unset! pop unset! _out unset! _res unset! _tmp unset! _str unset! mark unset! emit unset! load-json unset! indent unset! indent-level unset! normal-chars unset! escapes unset! init-state unset! emit-indent unset! emit-key-value unset! red-to-json-value unset! to-json unset! ignore-empty? unset! strict? unset! quote-char unset! double-quote unset! quotable-chars unset! parsed? unset! non-aligned unset! to-csv-line unset! escape-value unset! next-column-name unset! make-header unset! get-columns unset! encode-map unset! encode-maps unset! encode-flat unset! encode-blocks unset! load-csv unset! to-csv unset! ctx||362~encode unset! ctx||362~decode unset! reactor! unset! deep-reactor! unset! reactor unset! deep-reactor unset! relations unset! queue unset! eat-events? unset! source unset! add-relation unset! eval unset! eval-reaction unset! pending? unset! check unset! stop-reactor unset! clear-reactions unset! dump-reactions unset! is~ unset! is unset! react? unset! react unset! register-scheme unset! url-parser unset! =scheme unset! =user-info unset! =host unset! =port unset! =path unset! =query unset! =fragment unset! vars unset! alpha unset! alpha-num unset! hex-digit unset! gen-delims unset! sub-delims unset! reserved unset! unreserved unset! pct-encoded unset! alpha-num+ unset! scheme-char unset! url-rules unset! scheme-part unset! hier-part unset! authority unset! IP-literal unset! path-abempty unset! path-absolute unset! path-rootless unset! path-empty unset! any-segments unset! segment unset! segment-nz unset! segment-nz-nc unset! pchar unset! parse-url unset! decode-url unset! encode-url unset! preprocessor unset! exec unset! protos unset! macros unset! syms unset! depth unset! active? unset! trace? unset! s unset! do-quit unset! throw-error unset! syntax-error unset! do-safe unset! do-code unset! count-args unset! arg-mode? unset! func-arity? unset! value-path? unset! fetch-next unset! do-macro unset! register-macro unset! reset unset! expand unset! expand-directives unset! hex-to-rgb unset! within? unset! overlap? unset! distance? unset! event? unset! face? unset! size-text unset! caret-to-offset unset! offset-to-caret unset! offset-to-char unset! rich-text unset! rtd unset! color-stk unset! out unset! text unset! s-idx unset! pos unset! v unset! l unset! cur unset! pos1 unset! col unset! cols unset! nested unset! color unset! f-args unset! style! unset! style unset! tail-idx? unset! push-color unset! pop-color unset! close-colors unset! pop-all unset! optimize unset! rtd-layout unset! line-height? unset! line-count? unset! metrics? unset! set-flag unset! find-flag? unset! debug-info? unset! on-face-deep-change* unset! link-tabs-to-parent unset! link-sub-to-parent unset! update-font-faces unset! face! unset! offset unset! image unset! menu unset! enabled? unset! visible? unset! selected unset! flags unset! pane unset! rate unset! edge unset! para unset! font unset! actors unset! draw unset! font! unset! angle unset! anti-alias? unset! shadow unset! para! unset! origin unset! padding unset! scroll unset! align unset! v-align unset! wrap? unset! scroller! unset! position unset! page-size unset! min-size unset! max-size unset! vertical? unset! screens unset! event-port unset! metrics unset! screen-size unset! dpi unset! paddings unset! margins unset! def-heights unset! fixed-heights unset! misc unset! colors unset! fonts unset! fixed unset! sans-serif unset! serif unset! VID unset! handlers unset! evt-names unset! capture-events unset! capturing? unset! auto-sync? unset! silent? unset! make-null-handle unset! ctx||473~make-null-handle unset! get-screen-size unset! ctx||473~get-screen-size unset! ctx||473~size-text unset! on-change-facet unset! ctx||473~on-change-facet unset! update-font unset! ctx||473~update-font unset! update-para unset! ctx||473~update-para unset! destroy-view unset! ctx||473~destroy-view unset! update-view unset! ctx||473~update-view unset! refresh-window unset! ctx||473~refresh-window unset! redraw unset! ctx||473~redraw unset! show-window unset! ctx||473~show-window unset! make-view unset! ctx||473~make-view unset! draw-image unset! ctx||473~draw-image unset! draw-face unset! ctx||473~draw-face unset! do-event-loop unset! ctx||473~do-event-loop unset! exit-event-loop unset! ctx||473~exit-event-loop unset! request-font unset! ctx||473~request-font unset! request-file unset! ctx||473~request-file unset! request-dir unset! ctx||473~request-dir unset! text-box-metrics unset! ctx||473~text-box-metrics unset! update-scroller unset! ctx||473~update-scroller unset! init unset! product unset! styles unset! GUI-rules unset! processors unset! cancel-captions unset! ok-captions unset! no-capital unset! title-ize unset! sentence-ize unset! capitalize unset! adjust-buttons unset! Cancel-OK unset! general unset! process unset! containers unset! default-font unset! opts-proto unset! size-x unset! now? unset! process-reactors unset! calc-size unset! align-faces unset! resize-child-panels unset! clean-style unset! process-draw unset! add-option unset! add-flag unset! fetch-value unset! fetch-argument unset! fetch-expr unset! fetch-options unset! make-actor unset! layout unset! do-events unset! stop-events unset! do-actor unset! unview unset! center-face unset! make-face unset! dump-face unset! get-scroller unset! insert-event-func unset! remove-event-func unset! set-focus unset! foreach-face unset! buf unset! value unset! word unset! font-fixed unset! font-sans-serif unset! font-serif unset! reactors unset!
    ]] [#[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] 
        system #[object! [
            version: #[none]
            build: #[object! [
                date: #[none]
                git: #[object! [
                    branch: #[none]
                    tag: #[none]
                    ahead: #[none]
                    date: #[none]
                    commit: #[none]
                    message: #[none]
                ]]
                config: #[object! [
                    config-name: #[none]
                    OS: #[none]
                    OS-version: #[none]
                    ABI: #[none]
                    link?: #[none]
                    debug?: #[none]
                    encap?: #[none]
                    build-prefix: #[none]
                    build-basename: #[none]
                    build-suffix: #[none]
                    format: #[none]
                    type: #[none]
                    target: #[none]
                    cpu-version: #[none]
                    verbosity: #[none]
                    sub-system: #[none]
                    runtime?: #[none]
                    use-natives?: #[none]
                    debug-safe?: #[none]
                    dev-mode?: #[none]
                    need-main?: #[none]
                    PIC?: #[none]
                    base-address: #[none]
                    dynamic-linker: #[none]
                    syscall: #[none]
                    export-ABI: #[none]
                    stack-align-16?: #[none]
                    literal-pool?: #[none]
                    unicode?: #[none]
                    red-pass?: #[none]
                    red-only?: #[none]
                    red-store-bodies?: #[none]
                    red-strict-check?: #[none]
                    red-tracing?: #[none]
                    red-help?: #[none]
                    redbin-compress?: #[none]
                    legacy: #[none]
                    gui-console?: #[none]
                    libRed?: #[none]
                    libRedRT?: #[none]
                    libRedRT-update?: #[none]
                    GUI-engine: #[none]
                    modules: #[none]
                    show: #[none]
                    command-line: #[none]
                    show-func-map?: #[none]
                ]]
            ]]
            words: #[none]
            platform: #[none]
            catalog: #[object! [
                datatypes: #[none]
                actions: #[none]
                natives: #[none]
                accessors: #[none]
                errors: #[object! [
                    throw: #[object! [
                        code: #[none]
                        type: #[none]
                        break: #[none]
                        return: #[none]
                        throw: #[none]
                        continue: #[none]
                        while-cond: #[none]
                    ]]
                    note: #[object! [
                        code: #[none]
                        type: #[none]
                        no-load: #[none]
                    ]]
                    syntax: #[object! [
                        code: #[none]
                        type: #[none]
                        invalid: #[none]
                        missing: #[none]
                        no-header: #[none]
                        no-rs-header: #[none]
                        bad-header: #[none]
                        malconstruct: #[none]
                        bad-char: #[none]
                    ]]
                    script: #[object! [
                        code: #[none]
                        type: #[none]
                        no-value: #[none]
                        need-value: #[none]
                        not-defined: #[none]
                        not-in-context: #[none]
                        no-arg: #[none]
                        expect-arg: #[none]
                        expect-val: #[none]
                        expect-type: #[none]
                        cannot-use: #[none]
                        invalid-arg: #[none]
                        invalid-type: #[none]
                        invalid-type-spec: #[none]
                        invalid-op: #[none]
                        no-op-arg: #[none]
                        bad-op-spec: #[none]
                        invalid-data: #[none]
                        invalid-part: #[none]
                        not-same-type: #[none]
                        not-same-class: #[none]
                        not-related: #[none]
                        bad-func-def: #[none]
                        bad-func-arg: #[none]
                        bad-func-extern: #[none]
                        no-refine: #[none]
                        bad-refines: #[none]
                        bad-refine: #[none]
                        word-first: #[none]
                        empty-path: #[none]
                        invalid-path: #[none]
                        invalid-path-set: #[none]
                        invalid-path-get: #[none]
                        bad-path-type: #[none]
                        bad-path-set: #[none]
                        bad-field-set: #[none]
                        dup-vars: #[none]
                        past-end: #[none]
                        missing-arg: #[none]
                        out-of-range: #[none]
                        invalid-chars: #[none]
                        invalid-compare: #[none]
                        wrong-type: #[none]
                        invalid-refine-arg: #[none]
                        type-limit: #[none]
                        size-limit: #[none]
                        no-return: #[none]
                        throw-usage: #[none]
                        locked-word: #[none]
                        protected: #[none]
                        bad-bad: #[none]
                        bad-make-arg: #[none]
                        bad-to-arg: #[none]
                        invalid-months: #[none]
                        invalid-spec-field: #[none]
                        missing-spec-field: #[none]
                        move-bad: #[none]
                        too-long: #[none]
                        invalid-char: #[none]
                        bad-loop-series: #[none]
                        wrong-denom: #[none]
                        bad-denom: #[none]
                        invalid-obj-evt: #[none]
                        parse-rule: #[none]
                        parse-end: #[none]
                        parse-invalid-ref: #[none]
                        parse-block: #[none]
                        parse-unsupported: #[none]
                        parse-infinite: #[none]
                        parse-stack: #[none]
                        parse-keep: #[none]
                        parse-into-bad: #[none]
                        parse-into-type: #[none]
                        invalid-draw: #[none]
                        invalid-data-facet: #[none]
                        face-type: #[none]
                        not-window: #[none]
                        bad-window: #[none]
                        not-linked: #[none]
                        not-event-type: #[none]
                        invalid-facet-type: #[none]
                        vid-invalid-syntax: #[none]
                        rtd-invalid-syntax: #[none]
                        rtd-no-match: #[none]
                        react-bad-func: #[none]
                        react-not-enough: #[none]
                        react-no-match: #[none]
                        react-bad-obj: #[none]
                        react-gctx: #[none]
                        lib-invalid-arg: #[none]
                        buffer-not-enough: #[none]
                    ]]
                    math: #[object! [
                        code: #[none]
                        type: #[none]
                        zero-divide: #[none]
                        overflow: #[none]
                        positive: #[none]
                    ]]
                    access: #[object! [
                        code: #[none]
                        type: #[none]
                        cannot-open: #[none]
                        cannot-close: #[none]
                        invalid-utf8: #[none]
                        not-open: #[none]
                        no-connect: #[none]
                        no-scheme: #[none]
                        unknown-scheme: #[none]
                        invalid-spec: #[none]
                        invalid-port: #[none]
                        invalid-actor: #[none]
                        no-port-action: #[none]
                        no-create: #[none]
                        no-codec: #[none]
                        bad-media: #[none]
                        invalid-cmd: #[none]
                    ]]
                    reserved1: #[object! [
                        code: #[none]
                        type: #[none]
                    ]]
                    reserved2: #[object! [
                        code: #[none]
                        type: #[none]
                    ]]
                    user: #[object! [
                        code: #[none]
                        type: #[none]
                        message: #[none]
                    ]]
                    internal: #[object! [
                        code: #[none]
                        type: #[none]
                        bad-path: #[none]
                        not-here: #[none]
                        no-memory: #[none]
                        wrong-mem: #[none]
                        stack-overflow: #[none]
                        limit-hit: #[none]
                        too-deep: #[none]
                        no-cycle: #[none]
                        feature-na: #[none]
                        not-done: #[none]
                        invalid-error: #[none]
                        routines: #[none]
                        red-system: #[none]
                    ]]
                ]]
            ]]
            state: #[object! [
                interpreted?: #[datatype! function!]
                last-error: #[none]
                trace: #[none]
            ]]
            modules: #[none]
            codecs: #[none]
            schemes: #[none]
            ports: #[object! [
            ]]
            locale: #[object! [
                language: #[none]
                language*: #[none]
                locale: #[none]
                locale*: #[none]
                months: #[none]
                days: #[none]
                currencies: #[object! [
                    list: #[none]
                    on-change*: #[datatype! function!]
                    on-deep-change*: #[datatype! function!]
                ]]
            ]]
            options: #[object! [
                boot: #[none]
                home: #[none]
                path: #[none]
                script: #[none]
                cache: #[none]
                thru-cache: #[none]
                args: #[none]
                do-arg: #[none]
                debug: #[none]
                secure: #[none]
                quiet: #[none]
                binary-base: #[none]
                decimal-digits: #[none]
                money-digits: #[none]
                module-paths: #[none]
                file-types: #[none]
                float: #[object! [
                    pretty?: #[none]
                    full?: #[none]
                    on-change*: #[datatype! function!]
                ]]
                on-change*: #[datatype! function!]
                on-deep-change*: #[datatype! function!]
            ]]
            script: #[object! [
                title: #[none]
                header: #[none]
                parent: #[none]
                path: #[none]
                args: #[none]
            ]]
            standard: #[object! [
                header: #[object! [
                    title: #[none]
                    name: #[none]
                    type: #[none]
                    version: #[none]
                    date: #[none]
                    file: #[none]
                    author: #[none]
                    needs: #[none]
                ]]
                port: #[object! [
                    spec: #[none]
                    scheme: #[none]
                    actor: #[none]
                    awake: #[none]
                    state: #[none]
                    data: #[none]
                    extra: #[none]
                ]]
                error: #[object! [
                    code: #[none]
                    type: #[none]
                    id: #[none]
                    arg1: #[none]
                    arg2: #[none]
                    arg3: #[none]
                    near: #[none]
                    where: #[none]
                    stack: #[none]
                ]]
                file-info: #[object! [
                    name: #[none]
                    size: #[none]
                    date: #[none]
                    type: #[none]
                ]]
                url-parts: #[object! [
                    scheme: #[none]
                    user-info: #[none]
                    host: #[none]
                    port: #[none]
                    path: #[none]
                    target: #[none]
                    query: #[none]
                    fragment: #[none]
                    ref: #[none]
                ]]
                scheme: #[object! [
                    name: #[none]
                    title: #[none]
                    info: #[none]
                    actor: #[none]
                    awake: #[none]
                ]]
            ]]
            lexer: #[object! [
                pre-load: #[none]
                exit-states: #[none]
                tracer: #[none]
                lex: #[datatype! function!]
            ]]
            console: #[none]
            view: #[object! [
                screens: #[none]
                event-port: #[none]
                metrics: #[object! [
                    screen-size: #[none]
                    dpi: #[none]
                    paddings: #[none]
                    margins: #[none]
                    def-heights: #[none]
                    fixed-heights: #[none]
                    misc: #[none]
                    colors: #[none]
                ]]
                fonts: #[object! [
                    system: #[none]
                    fixed: #[none]
                    sans-serif: #[none]
                    serif: #[none]
                    size: #[none]
                ]]
                platform: #[object! [
                    make-null-handle: #[datatype! function!]
                    get-screen-size: #[datatype! function!]
                    size-text: #[datatype! function!]
                    on-change-facet: #[datatype! function!]
                    update-font: #[datatype! function!]
                    update-para: #[datatype! function!]
                    destroy-view: #[datatype! function!]
                    update-view: #[datatype! function!]
                    refresh-window: #[datatype! function!]
                    redraw: #[datatype! function!]
                    show-window: #[datatype! function!]
                    make-view: #[datatype! function!]
                    draw-image: #[datatype! function!]
                    draw-face: #[datatype! function!]
                    do-event-loop: #[datatype! function!]
                    exit-event-loop: #[datatype! function!]
                    request-font: #[datatype! function!]
                    request-file: #[datatype! function!]
                    request-dir: #[datatype! function!]
                    text-box-metrics: #[datatype! function!]
                    update-scroller: #[datatype! function!]
                    init: #[datatype! function!]
                    version: #[none]
                    build: #[none]
                    product: #[none]
                ]]
                VID: #[object! [
                    styles: #[none]
                    GUI-rules: #[object! [
                        active?: #[none]
                        debug?: #[none]
                        processors: #[object! [
                            cancel-captions: #[none]
                            ok-captions: #[none]
                            no-capital: #[none]
                            title-ize: #[datatype! function!]
                            sentence-ize: #[datatype! function!]
                            capitalize: #[datatype! function!]
                            adjust-buttons: #[datatype! function!]
                            Cancel-OK: #[datatype! function!]
                        ]]
                        general: #[none]
                        OS: #[none]
                        user: #[none]
                        process: #[datatype! function!]
                    ]]
                    debug?: #[none]
                    containers: #[none]
                    default-font: #[none]
                    opts-proto: #[object! [
                        type: #[none]
                        offset: #[none]
                        size: #[none]
                        size-x: #[none]
                        text: #[none]
                        color: #[none]
                        enabled?: #[none]
                        visible?: #[none]
                        selected: #[none]
                        image: #[none]
                        rate: #[none]
                        font: #[none]
                        flags: #[none]
                        options: #[none]
                        para: #[none]
                        data: #[none]
                        extra: #[none]
                        actors: #[none]
                        draw: #[none]
                        now?: #[none]
                        init: #[none]
                    ]]
                    throw-error: #[datatype! function!]
                    process-reactors: #[datatype! function!]
                    calc-size: #[datatype! function!]
                    align-faces: #[datatype! function!]
                    resize-child-panels: #[datatype! function!]
                    clean-style: #[datatype! function!]
                    process-draw: #[datatype! function!]
                    pre-load: #[datatype! function!]
                    add-option: #[datatype! function!]
                    add-flag: #[datatype! function!]
                    fetch-value: #[datatype! function!]
                    fetch-argument: #[datatype! function!]
                    fetch-expr: #[datatype! function!]
                    fetch-options: #[datatype! function!]
                    make-actor: #[datatype! function!]
                ]]
                handlers: #[none]
                evt-names: #[none]
                capture-events: #[datatype! function!]
                awake: #[datatype! function!]
                capturing?: #[none]
                auto-sync?: #[none]
                debug?: #[none]
                silent?: #[none]
            ]]
            reactivity: #[object! [
                relations: #[none]
                queue: #[none]
                eat-events?: #[none]
                debug?: #[none]
                source: #[none]
                add-relation: #[datatype! function!]
                eval: #[datatype! function!]
                eval-reaction: #[datatype! function!]
                pending?: #[datatype! function!]
                check: #[datatype! function!]
                is~: #[datatype! function!]
            ]]
        ]] ctx||224 225 #[none] #[none] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||226 (red/objects/system/build) ctx||226 227 #[none] #[none] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||228 (red/objects/system/build/git) ctx||228 229 #[none] #[none] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||230 (red/objects/system/build/config) ctx||230 231 #[none] #[none] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||232 (red/objects/system/catalog) ctx||232 233 #[none] #[none] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||234 (red/objects/system/catalog/errors) ctx||234 235 #[none] #[none] ctx||236 (red/objects/system/catalog/errors/throw) ctx||236 237 #[none] #[none] ctx||238 (red/objects/system/catalog/errors/note) ctx||238 239 #[none] #[none] ctx||240 (red/objects/system/catalog/errors/syntax) ctx||240 241 #[none] #[none] ctx||242 (red/objects/system/catalog/errors/script) ctx||242 243 #[none] #[none] ctx||244 (red/objects/system/catalog/errors/math) ctx||244 245 #[none] #[none] ctx||246 (red/objects/system/catalog/errors/access) ctx||246 247 #[none] #[none] ctx||248 (red/objects/system/catalog/errors/reserved1) ctx||248 249 #[none] #[none] ctx||250 (red/objects/system/catalog/errors/reserved2) ctx||250 251 #[none] #[none] ctx||252 (red/objects/system/catalog/errors/user) ctx||252 253 #[none] #[none] ctx||254 (red/objects/system/catalog/errors/internal) ctx||254 255 #[none] #[none] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||256 (red/objects/system/state) ctx||256 257 #[none] #[none] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||259 (red/objects/system/ports) ctx||259 260 #[none] #[none] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||261 (red/objects/system/locale) ctx||261 262 #[none] #[none] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||263 (red/objects/system/locale/currencies) ctx||263 264 #[none] [1 0 2 0 evt264] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||267 (red/objects/system/options) ctx||267 268 #[none] [17 0 18 0 evt268] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||269 (red/objects/system/options/float) ctx||269 270 #[none] [2 0 -1 0 evt270] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||274 (red/objects/system/script) ctx||274 275 #[none] #[none] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||276 (red/objects/system/standard) ctx||276 277 #[none] #[none] ctx||278 (red/objects/system/standard/header) ctx||278 279 #[none] #[none] ctx||280 (red/objects/system/standard/port) ctx||280 281 #[none] #[none] ctx||282 (red/objects/system/standard/error) ctx||282 283 #[none] #[none] ctx||284 (red/objects/system/standard/file-info) ctx||284 285 #[none] #[none] ctx||286 (red/objects/system/standard/url-parts) ctx||286 287 #[none] #[none] ctx||288 (red/objects/system/standard/scheme) ctx||288 289 #[none] #[none] #[none] #[object! [
            p-indent: #[none]
            on-parse-event: #[datatype! function!]
        ]] ctx||175 176 #[none] #[none] ctx||290 (red/objects/system/lexer) ctx||290 291 #[none] #[none] #[none] #[object! [
            title: #[none]
            name: #[none]
            mime-type: #[none]
            suffixes: #[none]
            encode: #[datatype! function!]
            decode: #[datatype! function!]
        ]] ctx||294 295 #[none] #[none] #[none] #[object! [
            title: #[none]
            name: #[none]
            mime-type: #[none]
            suffixes: #[none]
            encode: #[datatype! function!]
            decode: #[datatype! function!]
        ]] ctx||298 299 #[none] #[none] #[none] #[object! [
            title: #[none]
            name: #[none]
            mime-type: #[none]
            suffixes: #[none]
            encode: #[datatype! function!]
            decode: #[datatype! function!]
        ]] ctx||302 303 #[none] #[none] #[none] #[object! [
            title: #[none]
            name: #[none]
            mime-type: #[none]
            suffixes: #[none]
            encode: #[datatype! function!]
            decode: #[datatype! function!]
        ]] ctx||306 307 #[none] #[none] #[none] #[object! [
            Title: #[none]
            Name: #[none]
            Mime-Type: #[none]
            Suffixes: #[none]
            encode: #[datatype! function!]
            decode: #[datatype! function!]
        ]] ctx||310 311 #[none] #[none] #[none] #[object! [
            BOM: #[none]
            BOM-UTF-16?: #[datatype! function!]
            BOM-UTF-32?: #[datatype! function!]
            enquote: #[datatype! function!]
            high-surrogate?: #[datatype! function!]
            low-surrogate?: #[datatype! function!]
            translit: #[datatype! function!]
            json-to-red-escape-table: #[none]
            red-to-json-escape-table: #[none]
            json-esc-ch: #[none]
            json-escaped: #[none]
            red-esc-ch: #[none]
            decode-backslash-escapes: #[datatype! function!]
            encode-backslash-escapes: #[datatype! function!]
            ctrl-char: #[none]
            ws: #[none]
            ws*: #[none]
            ws+: #[none]
            sep: #[none]
            digit: #[none]
            non-zero-digit: #[none]
            hex-char: #[none]
            chars: #[none]
            not-word-char: #[none]
            word-1st: #[none]
            word-char: #[none]
            sign: #[none]
            int: #[none]
            frac: #[none]
            exp: #[none]
            number: #[none]
            numeric-literal: #[none]
            string-literal: #[none]
            decode-unicode-char: #[datatype! function!]
            replace-unicode-escapes: #[datatype! function!]
            json-object: #[none]
            property-list: #[none]
            property: #[none]
            json-name: #[none]
            array-list: #[none]
            json-array: #[none]
            json-value: #[none]
            stack: #[none]
            push: #[datatype! function!]
            pop: #[datatype! function!]
            _out: #[none]
            _res: #[none]
            _tmp: #[none]
            _str: #[none]
            mark: #[none]
            emit: #[datatype! function!]
        ]] ctx||319 320 #[none] #[none] #[none] #[object! [
            indent: #[none]
            indent-level: #[none]
            normal-chars: #[none]
            escapes: #[none]
            init-state: #[datatype! function!]
            emit-indent: #[datatype! function!]
            emit-key-value: #[datatype! function!]
            red-to-json-value: #[datatype! function!]
        ]] ctx||335 336 #[none] #[none] #[none] #[object! [
            Title: #[none]
            Name: #[none]
            Mime-Type: #[none]
            Suffixes: #[none]
            encode: #[datatype! function!]
            decode: #[datatype! function!]
        ]] ctx||343 344 #[none] #[none] #[none] #[object! [
            ignore-empty?: #[none]
            strict?: #[none]
            quote-char: #[none]
            double-quote: #[none]
            quotable-chars: #[none]
            parsed?: #[none]
            non-aligned: #[none]
            to-csv-line: #[datatype! function!]
            escape-value: #[datatype! function!]
            next-column-name: #[datatype! function!]
            make-header: #[datatype! function!]
            get-columns: #[datatype! function!]
            encode-map: #[datatype! function!]
            encode-maps: #[datatype! function!]
            encode-flat: #[datatype! function!]
            encode-blocks: #[datatype! function!]
        ]] ctx||348 349 #[none] #[none] context #[object! [
            title: #[none]
            name: #[none]
            mime-type: #[none]
            suffixes: #[none]
            encode: #[datatype! function!]
            decode: #[datatype! function!]
        ]] ctx||362 363 #[none] #[none] #[none] #[object! [
            title: #[none]
            name: #[none]
            mime-type: #[none]
            suffixes: #[none]
            encode: #[datatype! function!]
            decode: #[datatype! function!]
        ]] ctx||362 363 #[none] #[none] 
        reactor! #[object! [
            on-change*: #[datatype! function!]
        ]] ctx||365 366 #[none] [0 2 -1 0 evt366] 
        deep-reactor! #[object! [
            on-change*: #[datatype! function!]
            on-deep-change*: #[datatype! function!]
        ]] ctx||368 369 [#[object! [
                on-change*: #[datatype! function!]
            ]]] [0 2 1 0 evt369] ctx||373 (red/objects/system/reactivity) ctx||373 374 #[none] #[none] 
        url-parser #[object! [
            =scheme: #[none]
            =user-info: #[none]
            =host: #[none]
            =port: #[none]
            =path: #[none]
            =query: #[none]
            =fragment: #[none]
            vars: #[none]
            alpha: #[none]
            digit: #[none]
            alpha-num: #[none]
            hex-digit: #[none]
            gen-delims: #[none]
            sub-delims: #[none]
            reserved: #[none]
            unreserved: #[none]
            pct-encoded: #[none]
            alpha-num+: #[datatype! function!]
            scheme-char: #[none]
            url-rules: #[none]
            scheme-part: #[none]
            hier-part: #[none]
            authority: #[none]
            user-info: #[none]
            IP-literal: #[none]
            host: #[none]
            port: #[none]
            path-abempty: #[none]
            path-absolute: #[none]
            path-rootless: #[none]
            path-empty: #[none]
            any-segments: #[none]
            segment: #[none]
            segment-nz: #[none]
            segment-nz-nc: #[none]
            pchar: #[none]
            query: #[none]
            fragment: #[none]
            parse-url: #[datatype! function!]
        ]] ctx||388 389 #[none] #[none] #[none] #[object! [
            title: #[none]
            name: #[none]
            mime-type: #[none]
            suffixes: #[none]
            encode: #[datatype! function!]
            decode: #[datatype! function!]
        ]] ctx||362 363 #[none] #[none] 
        preprocessor #[object! [
            exec: #[none]
            protos: #[none]
            macros: #[none]
            stack: #[none]
            syms: #[none]
            depth: #[none]
            active?: #[none]
            trace?: #[none]
            s: #[none]
            do-quit: #[datatype! function!]
            throw-error: #[datatype! function!]
            syntax-error: #[datatype! function!]
            do-safe: #[datatype! function!]
            do-code: #[datatype! function!]
            count-args: #[datatype! function!]
            arg-mode?: #[datatype! function!]
            func-arity?: #[datatype! function!]
            value-path?: #[datatype! function!]
            fetch-next: #[datatype! function!]
            eval: #[datatype! function!]
            do-macro: #[datatype! function!]
            register-macro: #[datatype! function!]
            reset: #[datatype! function!]
            expand: #[datatype! function!]
        ]] ctx||394 395 #[none] #[none] #[none] #[object! [
            title: #[none]
            name: #[none]
            mime-type: #[none]
            suffixes: #[none]
            encode: #[datatype! function!]
            decode: #[datatype! function!]
        ]] ctx||362 363 #[none] #[none] 
        rich-text #[object! [
            rtd: #[object! [
                stack: #[none]
                color-stk: #[none]
                out: #[none]
                text: #[none]
                s-idx: #[none]
                s: #[none]
                pos: #[none]
                v: #[none]
                l: #[none]
                cur: #[none]
                pos1: #[none]
                mark: #[none]
                col: #[none]
                cols: #[none]
                nested: #[none]
                color: #[none]
                f-args: #[none]
                style!: #[none]
                style: #[none]
                rtd: #[none]
                tail-idx?: #[datatype! function!]
                push-color: #[datatype! function!]
                pop-color: #[datatype! function!]
                close-colors: #[datatype! function!]
                push: #[datatype! function!]
                pop: #[datatype! function!]
                pop-all: #[datatype! function!]
                optimize: #[datatype! function!]
            ]]
            line-height?: #[datatype! function!]
            line-count?: #[datatype! function!]
        ]] ctx||428 429 #[none] #[none] #[none] #[object! [
            title: #[none]
            name: #[none]
            mime-type: #[none]
            suffixes: #[none]
            encode: #[datatype! function!]
            decode: #[datatype! function!]
        ]] ctx||362 363 #[none] #[none] ctx||430 (red/objects/rich-text/rtd) ctx||430 431 #[none] #[none] 
        face! #[object! [
            type: #[none]
            offset: #[none]
            size: #[none]
            text: #[none]
            image: #[none]
            color: #[none]
            menu: #[none]
            data: #[none]
            enabled?: #[none]
            visible?: #[none]
            selected: #[none]
            flags: #[none]
            options: #[none]
            parent: #[none]
            pane: #[none]
            state: #[none]
            rate: #[none]
            edge: #[none]
            para: #[none]
            font: #[none]
            actors: #[none]
            extra: #[none]
            draw: #[none]
            on-change*: #[datatype! function!]
            on-deep-change*: #[datatype! function!]
        ]] ctx||450 451 #[none] [23 5 24 0 evt451] 
        font! #[object! [
            name: #[none]
            size: #[none]
            style: #[none]
            angle: #[none]
            color: #[none]
            anti-alias?: #[none]
            shadow: #[none]
            state: #[none]
            parent: #[none]
            on-change*: #[datatype! function!]
            on-deep-change*: #[datatype! function!]
        ]] ctx||454 455 #[none] [9 0 10 0 evt455] 
        para! #[object! [
            origin: #[none]
            padding: #[none]
            scroll: #[none]
            align: #[none]
            v-align: #[none]
            wrap?: #[none]
            parent: #[none]
            on-change*: #[datatype! function!]
        ]] ctx||458 459 #[none] [7 2 -1 0 evt459] 
        scroller! #[object! [
            position: #[none]
            page-size: #[none]
            min-size: #[none]
            max-size: #[none]
            visible?: #[none]
            vertical?: #[none]
            parent: #[none]
            on-change*: #[datatype! function!]
        ]] ctx||461 462 #[none] [7 0 -1 0 evt462] ctx||464 (red/objects/system/view) ctx||464 465 #[none] #[none] ctx||466 (red/objects/system/view/metrics) ctx||466 467 #[none] #[none] ctx||468 (red/objects/system/view/fonts) ctx||468 469 #[none] #[none] ctx||473 (red/objects/system/view/platform) ctx||473 474 #[none] #[none] ctx||479 (red/objects/system/view/VID) ctx||479 480 #[none] #[none] #[none] #[object! [
            title: #[none]
            name: #[none]
            mime-type: #[none]
            suffixes: #[none]
            encode: #[datatype! function!]
            decode: #[datatype! function!]
        ]] ctx||362 363 #[none] #[none] ctx||481 (red/objects/system/view/VID/GUI-rules) ctx||481 482 #[none] #[none] #[none] #[object! [
            title: #[none]
            name: #[none]
            mime-type: #[none]
            suffixes: #[none]
            encode: #[datatype! function!]
            decode: #[datatype! function!]
        ]] ctx||362 363 #[none] #[none] ctx||483 (red/objects/system/view/VID/GUI-rules/processors) ctx||483 484 #[none] #[none] ctx||491 (red/objects/system/view/VID/opts-proto) ctx||491 492 #[none] #[none]
    ] #[hash![ctx||53 [spec body] ctx||54 [msg] ctx||55 [
            value1 
            value2
        ] ctx||56 [
            value 
            safer
        ] ctx||57 [value] ctx||58 [
            return status
        ] ctx||59 [
            series
        ] ctx||60 [
            value
        ] ctx||61 [
            value
        ] ctx||62 [
            value
        ] ctx||63 [s] ctx||64 [s] ctx||65 [s] ctx||66 [s] ctx||67 [s] ctx||68 [s] ctx||69 [value] ctx||70 [value] ctx||71 [value] ctx||72 [value] ctx||73 [value] ctx||74 [value] ctx||75 [value] ctx||76 [value] ctx||77 [value] ctx||78 [value] ctx||79 [value] ctx||80 [value] ctx||81 [value] ctx||82 [value] ctx||83 [value] ctx||84 [value] ctx||85 [value] ctx||86 [value] ctx||87 [value] ctx||88 [value] ctx||89 [value] ctx||90 [value] ctx||91 [value] ctx||92 [value] ctx||93 [value] ctx||94 [value] ctx||95 [value] ctx||96 [value] ctx||97 [value] ctx||98 [value] ctx||99 [value] ctx||100 [value] ctx||101 [value] ctx||102 [value] ctx||103 [value] ctx||104 [value] ctx||105 [value] ctx||106 [value] ctx||107 [value] ctx||108 [value] ctx||109 [value] ctx||110 [value] ctx||111 [value] ctx||112 [value] ctx||113 [value] ctx||114 [value] ctx||115 [value] ctx||116 [value] ctx||117 [value] ctx||118 [value] ctx||119 [value] ctx||120 [value] ctx||121 [value] ctx||122 [value] ctx||123 [value] ctx||124 [value] ctx||125 [value] ctx||126 [value] ctx||127 [value] ctx||128 [value] ctx||129 [value] ctx||130 [value] ctx||131 [value] ctx||132 [value] ctx||133 [value] ctx||134 [value] ctx||135 [value] ctx||136 [value] ctx||137 [value] ctx||138 [value] ctx||139 [value] ctx||140 [value] ctx||141 [value] ctx||142 [value] ctx||143 [value] ctx||144 [value] ctx||145 [value] ctx||146 [value] ctx||147 [value] ctx||148 [value] ctx||149 [value] ctx||150 [value] ctx||151 [value] ctx||152 [value] ctx||153 [value] ctx||154 [value] ctx||155 [value] ctx||156 [value] ctx||157 [value] ctx||158 [value] ctx||159 [value] ctx||160 [value] ctx||161 [value] ctx||162 [value] ctx||163 [value] ctx||164 [value] ctx||165 [value] ctx||166 [value] ctx||167 [value] ctx||168 [
            spec
        ] ctx||169 [
            series 
            value
        ] ctx||170 [
            series1 
            series2
        ] ctx||171 [
            series 
            value 
            only
        ] ctx||172 [
            series 
            pattern 
            value 
            all 
            deep 
            case local parse? form? quote? deep? rule many? size seek
        ] ctx||173 [
            datum local match 
            order infix tally enter recur count operator
        ] ctx||174 [
            spec
        ] ctx||175 [
            p-indent 
            on-parse-event
        ] ctx||177 [
            event 
            match? 
            rule 
            input 
            stack
        ] ctx||178 [
            input 
            rules 
            case 
            part 
            limit
        ] ctx||179 [
            path
        ] ctx||180 [
            buffer 
            next 
            fast
        ] ctx||181 [
            source 
            header 
            all 
            trap 
            next 
            position 
            part 
            length 
            into 
            out 
            as 
            type local codec suffix name mime pre-load
        ] ctx||182 [
            where 
            value 
            header 
            header-data 
            all 
            length 
            as 
            format local dst codec data suffix find-encoder? name pos header-str k v
        ] ctx||183 [
            err-type 
            err-id 
            args
        ] ctx||184 [
            str 
            n 
            left 
            with 
            c
        ] ctx||185 [
            a 
            b local r
        ] ctx||186 [
            a 
            b local r
        ] ctx||187 [value1] ctx||188 [
            path local colon? slash? len i c dst
        ] ctx||189 [file] ctx||190 [
            dir
        ] ctx||191 [local path] ctx||192 [
            dir
        ] ctx||193 [
            path 
            deep local dirs end created dir
        ] ctx||194 [
            series 
            width 
            index 
            pos 
            into 
            output
        ] ctx||195 [local args at-arg2 ws buf s] ctx||196 [
            body 
            into 
            collected local keep rule pos
        ] ctx||197 [
            path local file buffer flag
        ] ctx||198 [
            series dlm local s 
            num
        ] ctx||199 [
            path
        ] ctx||200 [
            file 
            only 
            dir local out cnt f not-file? prot
        ] ctx||201 [
            target local dir pos
        ] ctx||202 [file local ws saved src code new-path header list c] ctx||203 [
            url local so hash file path
        ] ctx||204 [
            url
        ] ctx||205 [
            url 
            update 
            binary local path data
        ] ctx||206 [
            url 
            update 
            as 
            type local path file
        ] ctx||207 [
            url 
            update
        ] ctx||208 [
            angle
        ] ctx||209 [
            angle
        ] ctx||210 [
            angle
        ] ctx||211 [
            cosine
        ] ctx||212 [
            sine
        ] ctx||213 [
            tangent
        ] ctx||214 [
            y 
            x
        ] ctx||215 [
            number
        ] ctx||216 [
            date
        ] ctx||217 [
            date
        ] ctx||218 [
            src
        ] ctx||219 [
            block
        ] ctx||220 [
            values local result value
        ] ctx||221 [
            block
        ] ctx||222 [
            series
        ] ctx||223 [
            body local t0
        ] ctx||224 [
            version 
            build 
            words 
            platform 
            catalog 
            state 
            modules 
            codecs 
            schemes 
            ports 
            locale 
            options 
            script 
            standard 
            lexer 
            console 
            view 
            reactivity
        ] ctx||226 [
            date 
            git 
            config
        ] ctx||228 [
            branch 
            tag 
            ahead 
            date 
            commit 
            message
        ] ctx||230 [
            config-name 
            OS 
            OS-version 
            ABI 
            link? 
            debug? 
            encap? 
            build-prefix 
            build-basename 
            build-suffix 
            format 
            type 
            target 
            cpu-version 
            verbosity 
            sub-system 
            runtime? 
            use-natives? 
            debug-safe? 
            dev-mode? 
            need-main? 
            PIC? 
            base-address 
            dynamic-linker 
            syscall 
            export-ABI 
            stack-align-16? 
            literal-pool? 
            unicode? 
            red-pass? 
            red-only? 
            red-store-bodies? 
            red-strict-check? 
            red-tracing? 
            red-help? 
            redbin-compress? 
            legacy 
            gui-console? 
            libRed? 
            libRedRT? 
            libRedRT-update? 
            GUI-engine 
            modules 
            show 
            command-line 
            show-func-map?
        ] ctx||232 [
            datatypes 
            actions 
            natives 
            accessors 
            errors
        ] ctx||234 [
            throw 
            note 
            syntax 
            script 
            math 
            access 
            reserved1 
            reserved2 
            user 
            internal
        ] ctx||236 [
            code 
            type 
            break 
            return 
            throw 
            continue 
            while-cond
        ] ctx||238 [
            code 
            type 
            no-load
        ] ctx||240 [
            code 
            type 
            invalid 
            missing 
            no-header 
            no-rs-header 
            bad-header 
            malconstruct 
            bad-char
        ] ctx||242 [
            code 
            type 
            no-value 
            need-value 
            not-defined 
            not-in-context 
            no-arg 
            expect-arg 
            expect-val 
            expect-type 
            cannot-use 
            invalid-arg 
            invalid-type 
            invalid-type-spec 
            invalid-op 
            no-op-arg 
            bad-op-spec 
            invalid-data 
            invalid-part 
            not-same-type 
            not-same-class 
            not-related 
            bad-func-def 
            bad-func-arg 
            bad-func-extern 
            no-refine 
            bad-refines 
            bad-refine 
            word-first 
            empty-path 
            invalid-path 
            invalid-path-set 
            invalid-path-get 
            bad-path-type 
            bad-path-set 
            bad-field-set 
            dup-vars 
            past-end 
            missing-arg 
            out-of-range 
            invalid-chars 
            invalid-compare 
            wrong-type 
            invalid-refine-arg 
            type-limit 
            size-limit 
            no-return 
            throw-usage 
            locked-word 
            protected 
            bad-bad 
            bad-make-arg 
            bad-to-arg 
            invalid-months 
            invalid-spec-field 
            missing-spec-field 
            move-bad 
            too-long 
            invalid-char 
            bad-loop-series 
            wrong-denom 
            bad-denom 
            invalid-obj-evt 
            parse-rule 
            parse-end 
            parse-invalid-ref 
            parse-block 
            parse-unsupported 
            parse-infinite 
            parse-stack 
            parse-keep 
            parse-into-bad 
            parse-into-type 
            invalid-draw 
            invalid-data-facet 
            face-type 
            not-window 
            bad-window 
            not-linked 
            not-event-type 
            invalid-facet-type 
            vid-invalid-syntax 
            rtd-invalid-syntax 
            rtd-no-match 
            react-bad-func 
            react-not-enough 
            react-no-match 
            react-bad-obj 
            react-gctx 
            lib-invalid-arg 
            buffer-not-enough
        ] ctx||244 [
            code 
            type 
            zero-divide 
            overflow 
            positive
        ] ctx||246 [
            code 
            type 
            cannot-open 
            cannot-close 
            invalid-utf8 
            not-open 
            no-connect 
            no-scheme 
            unknown-scheme 
            invalid-spec 
            invalid-port 
            invalid-actor 
            no-port-action 
            no-create 
            no-codec 
            bad-media 
            invalid-cmd
        ] ctx||248 [
            code 
            type
        ] ctx||250 [
            code 
            type
        ] ctx||252 [
            code 
            type 
            message
        ] ctx||254 [
            code 
            type 
            bad-path 
            not-here 
            no-memory 
            wrong-mem 
            stack-overflow 
            limit-hit 
            too-deep 
            no-cycle 
            feature-na 
            not-done 
            invalid-error 
            routines 
            red-system
        ] ctx||256 [
            interpreted? 
            last-error 
            trace
        ] ctx||258 [] ctx||259 [] ctx||261 [
            language 
            language* 
            locale 
            locale* 
            months 
            days 
            currencies
        ] ctx||263 [
            list 
            on-change* 
            on-deep-change*
        ] ctx||265 [word old new] ctx||266 [owner word target action new index part] ctx||267 [
            boot 
            home 
            path 
            script 
            cache 
            thru-cache 
            args 
            do-arg 
            debug 
            secure 
            quiet 
            binary-base 
            decimal-digits 
            money-digits 
            module-paths 
            file-types 
            float 
            on-change* 
            on-deep-change*
        ] ctx||269 [
            pretty? 
            full? 
            on-change*
        ] ctx||271 [word old new] ctx||272 [word old new] ctx||273 [owner word target action new index part] ctx||274 [
            title header parent path 
            args
        ] ctx||276 [
            header 
            port 
            error 
            file-info 
            url-parts 
            scheme
        ] ctx||278 [
            title name type version date file author needs
        ] ctx||280 [
            spec scheme actor awake state data extra
        ] ctx||282 [
            code type id arg1 arg2 arg3 near where stack
        ] ctx||284 [
            name size date type
        ] ctx||286 [
            scheme user-info host port path target query fragment ref
        ] ctx||288 [
            name title info actor awake
        ] ctx||290 [
            pre-load 
            exit-states 
            tracer lex
        ] ctx||292 [
            event 
            input 
            type 
            line 
            token
        ] ctx||294 [
            title 
            name 
            mime-type 
            suffixes 
            encode 
            decode
        ] ctx||298 [
            title 
            name 
            mime-type 
            suffixes 
            encode 
            decode
        ] ctx||302 [
            title 
            name 
            mime-type 
            suffixes 
            encode 
            decode
        ] ctx||306 [
            title 
            name 
            mime-type 
            suffixes 
            encode 
            decode
        ] ctx||310 [
            Title 
            Name 
            Mime-Type 
            Suffixes 
            encode 
            decode
        ] ctx||317 [data where] ctx||318 [text] ctx||319 [
            BOM 
            BOM-UTF-16? 
            BOM-UTF-32? 
            enquote 
            high-surrogate? 
            low-surrogate? 
            translit 
            json-to-red-escape-table 
            red-to-json-escape-table 
            json-esc-ch 
            json-escaped 
            red-esc-ch 
            decode-backslash-escapes 
            encode-backslash-escapes 
            ctrl-char 
            ws 
            ws* 
            ws+ 
            sep 
            digit 
            non-zero-digit 
            hex-char 
            chars 
            not-word-char 
            word-1st 
            word-char 
            sign 
            int 
            frac 
            exp 
            number 
            numeric-literal 
            string-literal 
            decode-unicode-char 
            replace-unicode-escapes 
            json-object 
            property-list 
            property 
            json-name 
            array-list 
            json-array 
            json-value 
            stack 
            push 
            pop 
            _out 
            _res 
            _tmp 
            _str 
            mark 
            emit
        ] ctx||321 [data] ctx||322 [data] ctx||323 [str] ctx||324 [codepoint] ctx||325 [codepoint] ctx||326 [
            string 
            rule 
            xlat local val
        ] ctx||327 [string] ctx||328 [string] ctx||329 [
            ch
        ] ctx||330 [
            s local c
        ] ctx||331 [val] ctx||332 [] ctx||333 [value] ctx||334 [
            input
        ] ctx||335 [
            indent 
            indent-level 
            normal-chars 
            escapes 
            init-state 
            emit-indent 
            emit-key-value 
            red-to-json-value
        ] ctx||337 [ind ascii?] ctx||338 [output level] ctx||339 [output sep map key local value] ctx||340 [output value local special-char mark1 mark2 escape v keys k] ctx||341 [
            data 
            pretty indent 
            ascii local result
        ] ctx||343 [
            Title 
            Name 
            Mime-Type 
            Suffixes 
            encode 
            decode
        ] ctx||346 [data where] ctx||347 [text] ctx||348 [
            ignore-empty? 
            strict? 
            quote-char 
            double-quote 
            quotable-chars 
            parsed? 
            non-aligned 
            to-csv-line 
            escape-value 
            next-column-name 
            make-header 
            get-columns 
            encode-map 
            encode-maps 
            encode-flat 
            encode-blocks
        ] ctx||350 [
            data 
            delimiter
        ] ctx||351 [
            value 
            delimiter local quot? len
        ] ctx||352 [
            name local length index position previous
        ] ctx||353 [
            length local key
        ] ctx||354 [
            data local columns
        ] ctx||355 [
            data 
            delimiter local output keys length key index line
        ] ctx||356 [
            data 
            delimiter local columns value line column
        ] ctx||357 [
            data 
            delimiter 
            size
        ] ctx||358 [
            data 
            delimiter local length line csv-line
        ] ctx||359 [
            data 
            with 
            delimiter 
            header 
            as-columns 
            as-records 
            flat 
            trim 
            quote 
            qt-char local disallowed refs output out-map longest line value newline quotchars valchars quoted-value char normal-value s e single-value values add-value add-line length index line-rule init parsed? mark key-index key
        ] ctx||360 [
            data 
            with 
            delimiter 
            skip 
            size 
            quote 
            qt-char local longest keyval? types value
        ] ctx||362 [
            title 
            name 
            mime-type 
            suffixes 
            encode 
            decode
        ] ctx||365 [
            on-change*
        ] ctx||367 [word old new local srs] ctx||368 [on-change* 
            on-deep-change*
        ] ctx||370 [owner word target action new index part] ctx||371 [spec] ctx||372 [spec] ctx||373 [
            relations 
            queue 
            eat-events? 
            debug? 
            source 
            add-relation 
            eval 
            eval-reaction 
            pending? 
            check 
            is~
        ] ctx||375 [
            obj 
            word 
            reaction 
            targets local new-rel
        ] ctx||376 [code safe local result] ctx||377 [reactor reaction target mark] ctx||378 [reactor reaction local q] ctx||379 [reactor only field local pos reaction q q'] ctx||380 [
            face 
            deep local list pos f
        ] ctx||381 [] ctx||382 [local limit count obj field reaction target list] ctx||383 [
            field 
            reaction local obj rule item
        ] ctx||384 [
            reactor 
            field 
            target local pos
        ] ctx||385 [
            reaction 
            link 
            objects 
            unlink 
            src 
            later 
            with 
            ctx local objs found? rule item pos obj saved part path
        ] ctx||387 [
            spec 
            native 
            dispatch
        ] ctx||388 [
            =scheme =user-info =host =port =path =query =fragment 
            vars 
            alpha 
            digit 
            alpha-num 
            hex-digit 
            gen-delims 
            sub-delims 
            reserved 
            unreserved 
            pct-encoded 
            alpha-num+ 
            scheme-char 
            url-rules 
            scheme-part 
            hier-part 
            authority 
            user-info 
            IP-literal 
            host 
            port 
            path-abempty 
            path-absolute 
            path-rootless 
            path-empty 
            any-segments 
            segment 
            segment-nz 
            segment-nz-nc 
            pchar 
            query 
            fragment 
            parse-url
        ] ctx||390 [more] ctx||391 [
            url 
            throw-error local scheme user-info host port path target query fragment ref
        ] ctx||392 [
            url
        ] ctx||393 [url-obj local result] ctx||394 [
            exec 
            protos 
            macros 
            stack 
            syms 
            depth 
            active? 
            trace? 
            s 
            do-quit 
            throw-error 
            syntax-error 
            do-safe 
            do-code 
            count-args 
            arg-mode? 
            func-arity? 
            value-path? 
            fetch-next 
            eval 
            do-macro 
            register-macro 
            reset 
            expand
        ] ctx||396 [] ctx||397 [error cmd code local w] ctx||398 [s e] ctx||399 [code manual with cmd local res t? src] ctx||400 [code cmd local p] ctx||401 [spec block local total pos] ctx||402 [spec idx] ctx||403 [spec with path block local arity pos] ctx||404 [path local value i item selectable] ctx||405 [code local i left item item2 value fn-spec path f-arity at-op? op-mode] ctx||406 [code cmd local after expr] ctx||407 [name pos arity local cmd saved p v res] ctx||408 [spec local cnt rule p name macro pos valid? named?] ctx||409 [job] ctx||410 [
            code job 
            clean local rule e pos cond value then else cases body keep? expr src saved file
        ] ctx||411 [
            code 
            clean local job
        ] ctx||419 [
            hex local str bin
        ] ctx||420 [
            point 
            offset 
            size
        ] ctx||421 [
            A 
            B local A1 B1 A2 B2
        ] ctx||422 [
            A 
            B
        ] ctx||423 [
            value
        ] ctx||424 [
            face 
            with 
            text
        ] ctx||425 [
            face 
            pos 
            lower local opt
        ] ctx||426 [
            face 
            pt
        ] ctx||427 [
            face 
            pt
        ] ctx||428 [
            rtd 
            line-height? 
            line-count?
        ] ctx||430 [
            stack 
            color-stk 
            out text s-idx s pos v l cur pos1 
            mark col cols 
            nested 
            color 
            f-args 
            style! 
            style 
            rtd 
            tail-idx? 
            push-color 
            pop-color 
            close-colors 
            push 
            pop 
            pop-all 
            optimize
        ] ctx||432 [] ctx||433 [c] ctx||434 [local entry pos] ctx||435 [local pos] ctx||436 [style] ctx||437 [style local entry type] ctx||438 [mark local first? i] ctx||439 [local cur pos range pos1 e s l mov] ctx||440 [
            spec 
            only 
            with 
            face
        ] ctx||441 [
            face 
            pos
        ] ctx||442 [
            face
        ] ctx||443 [
            face 
            type 
            total 
            axis local res
        ] ctx||444 [
            face 
            facet 
            value local flags
        ] ctx||445 [face] ctx||446 [owner word target action new index part state forced? local faces face modal? pane] ctx||447 [
            face 
            init local faces visible?
        ] ctx||448 [face type old new local parent] ctx||449 [parent local f] ctx||450 [
            type 
            offset 
            size 
            text 
            image 
            color 
            menu 
            data 
            enabled? 
            visible? 
            selected 
            flags 
            options 
            parent 
            pane 
            state 
            rate 
            edge 
            para 
            font 
            actors 
            extra 
            draw 
            on-change* 
            on-deep-change*
        ] ctx||452 [word old new local srs same-pane? f saved] ctx||453 [owner word target action new index part] ctx||454 [
            name 
            size 
            style 
            angle 
            color 
            anti-alias? 
            shadow 
            state 
            parent 
            on-change* 
            on-deep-change*
        ] ctx||456 [word old new] ctx||457 [owner word target action new index part] ctx||458 [
            origin 
            padding 
            scroll 
            align 
            v-align 
            wrap? 
            parent 
            on-change*
        ] ctx||460 [word old new local f] ctx||461 [
            position 
            page-size 
            min-size 
            max-size 
            visible? 
            vertical? 
            parent 
            on-change*
        ] ctx||463 [word old new] ctx||464 [
            screens 
            event-port 
            metrics 
            fonts 
            platform 
            VID 
            handlers 
            evt-names 
            capture-events 
            awake 
            capturing? 
            auto-sync? 
            debug? 
            silent?
        ] ctx||466 [
            screen-size 
            dpi 
            paddings 
            margins 
            def-heights 
            fixed-heights 
            misc 
            colors
        ] ctx||468 [
            system 
            fixed 
            sans-serif 
            serif 
            size
        ] ctx||470 [face event local result] ctx||471 [event with face local result 
            handler
        ] ctx||473 [
            make-null-handle 
            get-screen-size 
            size-text 
            on-change-facet 
            update-font 
            update-para 
            destroy-view 
            update-view 
            refresh-window 
            redraw 
            show-window 
            make-view 
            draw-image 
            draw-face 
            do-event-loop 
            exit-event-loop 
            request-font 
            request-file 
            request-dir 
            text-box-metrics 
            update-scroller 
            init 
            version 
            build 
            product
        ] ctx||475 [local svs colors fonts] ctx||478 [
            image 
            cmd 
            transparent
        ] ctx||479 [
            styles 
            GUI-rules 
            debug? 
            containers 
            default-font 
            opts-proto 
            throw-error 
            process-reactors 
            calc-size 
            align-faces 
            resize-child-panels 
            clean-style 
            process-draw 
            pre-load 
            add-option 
            add-flag 
            fetch-value 
            fetch-argument 
            fetch-expr 
            fetch-options 
            make-actor
        ] ctx||481 [
            active? 
            debug? 
            processors 
            general 
            OS 
            user 
            process
        ] ctx||483 [
            cancel-captions 
            ok-captions 
            no-capital 
            title-ize 
            sentence-ize 
            capitalize 
            adjust-buttons 
            Cancel-OK
        ] ctx||485 [text local p] ctx||486 [text local h s e] ctx||487 [
            root local rule pos
        ] ctx||488 [
            root local def-margins def-margin-yy opts class svmm y align axis marg def-marg
        ] ctx||489 [
            root local pos-x last-but pos-y f
        ] ctx||490 [root local list name] ctx||491 [
            type offset size size-x text color enabled? visible? selected image 
            rate font flags options para data extra actors draw now? init
        ] ctx||493 [spec] ctx||494 [reactors local res 
            f blk later? ctx face
        ] ctx||495 [face local min-sz data txt s len mark e new] ctx||496 [pane dir align max-sz local edge? top-left? axis svmm face offset mar type] ctx||497 [tab local tp-size pad pane] ctx||498 [tmpl type local para font] ctx||499 [code local rule pos color] ctx||500 [value local color] ctx||501 [opts spec local field value] ctx||502 [obj facet field flag local blk] ctx||503 [blk local value] ctx||504 [expected pos local spec type value] ctx||505 [code] ctx||506 [
            face opts style spec css reactors styling? 
            no-skip local opt? divides calc-y? do-with obj-spec! rate! color! cursor! value match? drag-on default hint cursor tight? later? max-sz p words user-size? oi x font face-font field actors name f s b pad sz min-sz mar
        ] ctx||507 [obj name body spec] ctx||508 [
            spec 
            tight 
            options 
            user-opts 
            flags 
            flgs 
            only 
            parent 
            panel 
            divides 
            styles 
            css local axis anti 
            background! list reactors local-styles pane-size direction align begin size max-sz current global? below? top-left bound cursor origin spacing opts opt-words re-align sz words reset focal-face svmp pad value anti2 at-offset later? name styling? style styled? st actors face h pos styled w blk vid-align mar divide? index dir pad2 image
        ] ctx||511 [
            no-wait local result 
            win
        ] ctx||512 [] ctx||513 [code local result] ctx||514 [face event type local result 
            act name
        ] ctx||515 [
            face 
            with 
            parent 
            force local show? f pending owner word target action new index part state new? p obj field pane
        ] ctx||516 [
            all 
            only 
            face local all? svs pane
        ] ctx||517 [
            spec 
            tight 
            options 
            opts 
            flags 
            flgs 
            no-wait
        ] ctx||518 [
            face 
            x 
            y 
            with 
            parent local pos
        ] ctx||519 [
            style 
            spec 
            blk 
            offset 
            xy 
            size 
            wh local 
            svv face styles model opts css
        ] ctx||520 [
            face local depth f
        ] ctx||521 [
            face 
            orientation local position page min-size max-size parent vertical?
        ] ctx||522 [
            fun
        ] ctx||523 [
            fun
        ] ctx||524 [
            font 
            ft 
            mono
        ] ctx||525 [
            title 
            text 
            file 
            name 
            filter 
            list 
            save 
            multi
        ] ctx||526 [
            title 
            text 
            dir 
            name 
            filter 
            list 
            keep 
            multi
        ] ctx||527 [
            face local p
        ] ctx||528 [
            face 
            body 
            with 
            spec 
            post 
            sub post? local exec
        ] ctx||575 [v only] ctx||633 [
            scheme 
            user-info 
            host 
            port 
            path 
            target 
            query 
            fragment 
            ref
        ] ctx||821 [face]]] [
        random 
        reflect 
        to 
        form 
        mold 
        modify 
        absolute 
        add 
        divide 
        multiply 
        negate 
        power 
        remainder 
        round 
        subtract 
        even? 
        odd? 
        and~ 
        complement 
        or~ 
        xor~ 
        append 
        at 
        back 
        change 
        clear 
        copy 
        find 
        head 
        head? 
        index? 
        insert 
        length? 
        move 
        next 
        pick 
        poke 
        put 
        remove 
        reverse 
        select 
        sort 
        skip 
        swap 
        tail 
        tail? 
        take 
        trim 
        create 
        close 
        delete 
        open 
        open? 
        query 
        read 
        rename 
        update 
        write
    ] [+ add - subtract * multiply / divide // modulo %"" remainder = equal? <> not-equal? == strict-equal? =? same? < lesser? > greater? <= lesser-or-equal? >= greater-or-equal? << shift-left >> shift-right ">>>" shift-logical ** power 
        and and~ 
        or or~ 
        xor xor~ is ctx||373~is~
    ] [datatype! 
        make unset! none! logic! block! string! integer! word! error! typeset! file! url! set-word! get-word! lit-word! refinement! binary! paren! char! issue! path! set-path! get-path! lit-path! native! action! op! function! routine! object! bitset! float! point! vector! map! hash! pair! percent! tuple! image! time! tag! email! handle! date! port! money! ref! event! none set true false random reflect to form mold modify absolute add divide multiply negate power remainder round subtract even? odd? complement append at back change clear copy find head head? index? insert length? move next pick poke put remove reverse select sort skip swap tail tail? take trim create close delete open open? query read rename update write if unless either any all while until loop repeat forever foreach forall remove-each func function does has switch case do reduce compose get print prin equal? not-equal? strict-equal? lesser? greater? lesser-or-equal? greater-or-equal? same? not type? stats bind in parse union unique intersect difference exclude complement? dehex enhex negative? positive? max min shift to-hex sine cosine tangent arcsine arccosine arctangent arctangent2 NaN? zero? log-2 log-10 log-e exp square-root construct value? try uppercase lowercase as-pair as-money break continue exit return throw catch extend debase enbase to-local-file wait checksum unset new-line new-line? context? set-env get-env list-env now sign? as call size? browse compress decompress recycle transcode quit-return set-quiet set-slot-quiet shift-right shift-left shift-logical last-lf? get-current-dir set-current-dir create-dir exists? os-info as-color as-ipv4 as-rgba count-chars read-clipboard write-clipboard write-stdout yes on no off tab cr newline lf escape slash sp space null crlf dot comma dbl-quote pi Rebol internal! external! number! scalar! any-word! all-word! any-list! any-path! any-block! any-function! any-object! any-string! series! immediate! default! any-type! aqua beige black blue brick brown coal coffee crimson cyan forest gold gray green ivory khaki leaf linen magenta maroon mint navy oldrab olive orange papaya pewter pink purple reblue rebolor red sienna silver sky snow tanned teal violet water wheat white yello yellow glass transparent routine alert also attempt comment quit empty? ?? probe quote first second third fourth fifth last spec-of body-of words-of class-of values-of bitset? binary? block? char? email? file? float? get-path? get-word? hash? integer? issue? lit-path? lit-word? logic? map? none? pair? paren? path? percent? refinement? set-path? set-word? string? tag? time? typeset? tuple? unset? url? word? image? date? money? ref? handle? error? action? native? datatype? function? object? op? routine? vector? any-list? any-block? any-function? any-object? any-path? any-string? any-word? series? number? immediate? scalar? all-word? to-bitset to-binary to-block to-char to-email to-file to-float to-get-path to-get-word to-hash to-integer to-issue to-lit-path to-lit-word to-logic to-map to-none to-pair to-paren to-path to-percent to-refinement to-set-path to-set-word to-string to-tag to-time to-typeset to-tuple to-unset to-url to-word to-image to-date to-money to-ref context alter offset? repend replace math charset body p-indent on-parse-event parse-trace suffix? scan load save cause-error pad mod modulo eval-set-path to-red-file dir? normalize-dir what-dir change-dir make-dir extract extract-boot-args collect flip-exe-flag split dirize clean-path split-path do-file path-thru exists-thru? read-thru load-thru do-thru cos sin tan acos asin atan atan2 sqrt to-UTC-date to-local-date transcode-trace rejoin sum average last? dt single? keys-of object halt system version build date git branch tag ahead commit message config config-name Darwin OS macOS OS-version ABI link? debug? encap? build-prefix build-basename build-suffix format Mach-O type dll target IA-32 cpu-version verbosity sub-system console runtime? use-natives? debug-safe? dev-mode? need-main? PIC? base-address dynamic-linker syscall BSD export-ABI stack-align-16? literal-pool? unicode? red-pass? red-only? red-store-bodies? red-strict-check? red-tracing? red-help? redbin-compress? legacy gui-console? libRed? libRedRT? libRedRT-update? GUI-engine native modules show command-line show-func-map? words platform catalog datatypes actions natives accessors errors code while-cond note no-load syntax invalid missing no-header no-rs-header bad-header malconstruct bad-char script no-value need-value not-defined not-in-context no-arg expect-arg expect-val expect-type cannot-use invalid-arg invalid-type invalid-type-spec invalid-op no-op-arg bad-op-spec invalid-data invalid-part not-same-type not-same-class not-related bad-func-def bad-func-arg bad-func-extern no-refine bad-refines bad-refine word-first empty-path invalid-path invalid-path-set invalid-path-get bad-path-type bad-path-set bad-field-set dup-vars past-end missing-arg out-of-range invalid-chars invalid-compare wrong-type invalid-refine-arg type-limit size-limit no-return throw-usage locked-word protected bad-bad bad-make-arg bad-to-arg invalid-months invalid-spec-field missing-spec-field move-bad too-long invalid-char bad-loop-series wrong-denom bad-denom invalid-obj-evt parse-rule parse-end parse-invalid-ref parse-block parse-unsupported parse-infinite parse-stack parse-keep parse-into-bad parse-into-type invalid-draw invalid-data-facet face-type not-window bad-window not-linked not-event-type invalid-facet-type vid-invalid-syntax rtd-invalid-syntax rtd-no-match react-bad-func react-not-enough react-no-match react-bad-obj react-gctx lib-invalid-arg buffer-not-enough zero-divide overflow positive access cannot-open cannot-close invalid-utf8 not-open no-connect no-scheme unknown-scheme invalid-spec invalid-port invalid-actor no-port-action no-create no-codec bad-media invalid-cmd reserved1 reserved2 user internal bad-path not-here no-memory wrong-mem stack-overflow limit-hit too-deep no-cycle feature-na not-done invalid-error routines red-system state interpreted? last-error trace codecs schemes ports locale language language* locale* months days currencies list on-change* on-deep-change* options boot home path cache thru-cache args do-arg debug secure quiet binary-base decimal-digits money-digits module-paths file-types float pretty? full? title header parent standard name file author needs port spec scheme actor awake data extra error id arg1 arg2 arg3 near where stack file-info size url-parts user-info host fragment ref info lexer pre-load exit-states 
        eof hex rawstring tracer lex view reactivity + - * / // %"" = <> == =? < > <= >= << >> ">>>" ** and or xor eval-path codecs png PNG mime-type suffixes encode decode codecs jpeg JPEG codecs bmp BMP codecs gif GIF codecs json Title Name JSON Mime-Type Suffixes BOM BOM-UTF-16? BOM-UTF-32? enquote high-surrogate? low-surrogate? translit json-to-red-escape-table red-to-json-escape-table json-esc-ch json-escaped red-esc-ch decode-backslash-escapes encode-backslash-escapes ctrl-char ws ws* ws+ sep digit non-zero-digit hex-char chars not-word-char word-1st word-char sign int frac number numeric-literal string-literal decode-unicode-char replace-unicode-escapes json-object property-list property json-name array-list json-array json-value push pop _out _res _tmp _str mark emit load-json indent indent-level normal-chars escapes init-state emit-indent emit-key-value red-to-json-value to-json codecs csv CSV ignore-empty? strict? quote-char double-quote quotable-chars parsed? non-aligned to-csv-line escape-value next-column-name make-header get-columns encode-map encode-maps encode-flat encode-blocks load-csv to-csv codecs redbin Redbin reactor! deep-reactor! reactor deep-reactor relations queue eat-events? source add-relation eval eval-reaction pending? check stop-reactor clear-reactions dump-reactions is react? react reactivity register-scheme url-parser =scheme =user-info =host =port =path =query =fragment vars alpha alpha-num hex-digit gen-delims sub-delims reserved unreserved pct-encoded alpha-num+ scheme-char url-rules scheme-part hier-part authority IP-literal path-abempty path-absolute path-rootless path-empty any-segments segment segment-nz segment-nz-nc pchar parse-url decode-url encode-url preprocessor exec protos macros syms depth active? trace? s do-quit throw-error syntax-error do-safe do-code count-args arg-mode? func-arity? value-path? fetch-next do-macro register-macro reset expand expand-directives version version platform Windows options cache script args hex-to-rgb within? overlap? distance? event? face? size-text caret-to-offset offset-to-caret offset-to-char rich-text rtd color-stk out text s-idx pos v l cur pos1 col cols nested color f-args style! style tail-idx? push-color pop-color close-colors pop-all optimize rtd-layout line-height? line-count? metrics? set-flag find-flag? debug-info? on-face-deep-change* link-tabs-to-parent link-sub-to-parent update-font-faces face! face offset image menu enabled? visible? selected flags pane rate edge para font actors draw font! angle anti-alias? shadow para! origin padding scroll align v-align wrap? scroller! position page-size min-size max-size vertical? screens event-port metrics screen-size dpi paddings margins def-heights fixed-heights misc colors fonts fixed sans-serif serif VID handlers evt-names capture-events capturing? auto-sync? silent? view make-null-handle get-screen-size on-change-facet update-font update-para destroy-view update-view refresh-window redraw show-window make-view draw-image draw-face do-event-loop exit-event-loop request-font request-file request-dir text-box-metrics update-scroller init product view platform styles GUI-rules processors cancel-captions ok-captions no-capital title-ize sentence-ize capitalize adjust-buttons Cancel-OK general process containers default-font opts-proto size-x now? process-reactors calc-size align-faces resize-child-panels clean-style process-draw add-option add-flag fetch-value fetch-argument fetch-expr fetch-options make-actor layout view VID do-events stop-events do-actor unview center-face make-face dump-face get-scroller insert-event-func remove-event-func set-focus foreach-face modal value1 value console console class values 
        else series pattern operator select-key* codecs paren codec codecs suffixes codecs mime mime-type Content-Type Content-Type lexer pre-load codecs codecs suffixes length k options path options path options path dir script args options args options boot options args keep flag options path Red c locale currencies list options so thru-cache cache thru-cache MD5 thru-cache timezone timezone timezone lexer tracer appended UTF-16-BE UTF-16-BE UTF-16-LE UTF-16-LE UTF-32-BE UTF-32-BE UTF-32-LE UTF-32-LE buf index key refs out-map line reactivity debug? reactivity source srs owned only reactivity debug? reactivity source result q pane f pane console x console size x obj field reaction actor schemes name name schemes url-obj scheme scheme host user-info user-info host port port path path path target target query query fragment fragment options args console halt-request where console res word i item left f-arity p | config rule build config str bin point x x y y y x x x y y y A offset B offset size size A1 x B2 x B1 x A2 x y y y y offset x offset x size x size x offset y offset y size y size y type _ entry bold italic underline strike backdrop text data data view metrics type options options class x y view debug? gui-console-ctx terminal box terminal box console win win caret caret view auto-sync? owner type screen moved faces parent type type window flags state enabled? view auto-sync? flags parent type type type type tab-panel visible? parent type type type type text options default options default type data data pane visible? parent new parent parent state state state draw state state reactivity source type parent state state self default view auto-sync? view debug? view debug? state state state state parent parent detect event face handler type parent with parent stop type state view screens pane view screens view metrics margins view metrics paddings view metrics fixed-heights view metrics def-heights view metrics colors view fonts platform font-fixed font-sans-serif font-serif view metrics margins platform view silent? silent blk later? type data txt text type drop-list scroller view metrics misc scroller min-sz x x y type area text text text text across middle below center view metrics margins at-offset options at-offset size view metrics margins type options class mar x x y y x x y y offset offset pane size view metrics paddings tab-panel x y x y pane size tmpl para parent para font parent font opts options options options font color view VID styles view evt-names size size text text data data image image color color size type size y size size-x type pane data panel pane offset size size size default-actor default-actor default-actor styled size-x template template size x size-x size type base data data image data image size-x size size-x oi size x size x size x size size y size size type data data data font font font face-font actors actors b actors actors actors actors view metrics paddings type x y x y size-x size-x size type text data font size-x size-x sz y y size size view metrics margins type size x y x y size type actors actors local actors actors top view VID styles window template pane pane pane view metrics paddings type svmp x x draw text color image view evt-names axis anti cursor spacing later view VID styles template st type actors actors actors actors view metrics def-heights type size y size y parent init init template type init init init init init w offset options at-offset view metrics margins type offset x x offset size offset size offset offset color type type color offset size now? time view metrics fixed-heights type type progress size y size x offset size offset size size y y size image size size size pane selected flags flags flags actors actors actors pane type view screens parent view screens pane state state state actors actors view evt-names state state state state action part state type type parent parent type parent extra extra extra actors actors on-create state type pane pane parent state parent type view screens pane flags enabled? view auto-sync? state pane pane state state actors actors on-created type visible? view debug? view screens svs pane view screens type flags flags flags text text offset type view screens parent size size x offset x y offset x offset type offset offset offset view VID svv styles model template opts-proto reactors no-skip init init offset size pane pane view handlers view handlers parent type parent selected pane pane pane
    ] [
        ctx||53: get-root-node2 103 
        ctx||54: get-root-node2 106 
        ctx||55: get-root-node2 109 
        ctx||56: get-root-node2 112 
        ctx||57: get-root-node2 115 
        ctx||58: get-root-node2 118 
        ctx||59: get-root-node2 121 
        ctx||60: get-root-node2 124 
        ctx||61: get-root-node2 127 
        ctx||62: get-root-node2 130 
        ctx||63: get-root-node2 133 
        ctx||64: get-root-node2 136 
        ctx||65: get-root-node2 139 
        ctx||66: get-root-node2 142 
        ctx||67: get-root-node2 145 
        ctx||68: get-root-node2 148 
        ctx||69: get-root-node2 151 
        ctx||70: get-root-node2 154 
        ctx||71: get-root-node2 157 
        ctx||72: get-root-node2 160 
        ctx||73: get-root-node2 163 
        ctx||74: get-root-node2 166 
        ctx||75: get-root-node2 169 
        ctx||76: get-root-node2 172 
        ctx||77: get-root-node2 175 
        ctx||78: get-root-node2 178 
        ctx||79: get-root-node2 181 
        ctx||80: get-root-node2 184 
        ctx||81: get-root-node2 187 
        ctx||82: get-root-node2 190 
        ctx||83: get-root-node2 193 
        ctx||84: get-root-node2 196 
        ctx||85: get-root-node2 199 
        ctx||86: get-root-node2 202 
        ctx||87: get-root-node2 205 
        ctx||88: get-root-node2 208 
        ctx||89: get-root-node2 211 
        ctx||90: get-root-node2 214 
        ctx||91: get-root-node2 217 
        ctx||92: get-root-node2 220 
        ctx||93: get-root-node2 223 
        ctx||94: get-root-node2 226 
        ctx||95: get-root-node2 229 
        ctx||96: get-root-node2 232 
        ctx||97: get-root-node2 235 
        ctx||98: get-root-node2 238 
        ctx||99: get-root-node2 241 
        ctx||100: get-root-node2 244 
        ctx||101: get-root-node2 247 
        ctx||102: get-root-node2 250 
        ctx||103: get-root-node2 253 
        ctx||104: get-root-node2 256 
        ctx||105: get-root-node2 259 
        ctx||106: get-root-node2 262 
        ctx||107: get-root-node2 265 
        ctx||108: get-root-node2 268 
        ctx||109: get-root-node2 271 
        ctx||110: get-root-node2 274 
        ctx||111: get-root-node2 277 
        ctx||112: get-root-node2 280 
        ctx||113: get-root-node2 283 
        ctx||114: get-root-node2 286 
        ctx||115: get-root-node2 289 
        ctx||116: get-root-node2 292 
        ctx||117: get-root-node2 295 
        ctx||118: get-root-node2 298 
        ctx||119: get-root-node2 301 
        ctx||120: get-root-node2 304 
        ctx||121: get-root-node2 307 
        ctx||122: get-root-node2 310 
        ctx||123: get-root-node2 313 
        ctx||124: get-root-node2 316 
        ctx||125: get-root-node2 319 
        ctx||126: get-root-node2 322 
        ctx||127: get-root-node2 325 
        ctx||128: get-root-node2 328 
        ctx||129: get-root-node2 331 
        ctx||130: get-root-node2 334 
        ctx||131: get-root-node2 337 
        ctx||132: get-root-node2 340 
        ctx||133: get-root-node2 343 
        ctx||134: get-root-node2 346 
        ctx||135: get-root-node2 349 
        ctx||136: get-root-node2 352 
        ctx||137: get-root-node2 355 
        ctx||138: get-root-node2 358 
        ctx||139: get-root-node2 361 
        ctx||140: get-root-node2 364 
        ctx||141: get-root-node2 367 
        ctx||142: get-root-node2 370 
        ctx||143: get-root-node2 373 
        ctx||144: get-root-node2 376 
        ctx||145: get-root-node2 379 
        ctx||146: get-root-node2 382 
        ctx||147: get-root-node2 385 
        ctx||148: get-root-node2 388 
        ctx||149: get-root-node2 391 
        ctx||150: get-root-node2 394 
        ctx||151: get-root-node2 397 
        ctx||152: get-root-node2 400 
        ctx||153: get-root-node2 403 
        ctx||154: get-root-node2 406 
        ctx||155: get-root-node2 409 
        ctx||156: get-root-node2 412 
        ctx||157: get-root-node2 415 
        ctx||158: get-root-node2 418 
        ctx||159: get-root-node2 421 
        ctx||160: get-root-node2 424 
        ctx||161: get-root-node2 427 
        ctx||162: get-root-node2 430 
        ctx||163: get-root-node2 433 
        ctx||164: get-root-node2 436 
        ctx||165: get-root-node2 439 
        ctx||166: get-root-node2 442 
        ctx||167: get-root-node2 445 
        ctx||168: get-root-node2 448 
        ctx||169: get-root-node2 451 
        ctx||170: get-root-node2 454 
        ctx||171: get-root-node2 457 
        ctx||172: get-root-node2 460 
        ctx||173: get-root-node2 463 
        ctx||174: get-root-node2 466 
        ctx||175: get-root-node2 469 
        ctx||177: get-root-node2 470 
        ctx||178: get-root-node2 473 
        ctx||179: get-root-node2 476 
        ctx||180: get-root-node2 479 
        ctx||181: get-root-node2 482 
        ctx||182: get-root-node2 485 
        ctx||183: get-root-node2 488 
        ctx||184: get-root-node2 491 
        ctx||185: get-root-node2 494 
        ctx||186: get-root-node2 497 
        ctx||187: get-root-node2 500 
        ctx||188: get-root-node2 503 
        ctx||189: get-root-node2 506 
        ctx||190: get-root-node2 509 
        ctx||191: get-root-node2 512 
        ctx||192: get-root-node2 515 
        ctx||193: get-root-node2 518 
        ctx||194: get-root-node2 521 
        ctx||195: get-root-node2 524 
        ctx||196: get-root-node2 527 
        ctx||197: get-root-node2 530 
        ctx||198: get-root-node2 533 
        ctx||199: get-root-node2 536 
        ctx||200: get-root-node2 539 
        ctx||201: get-root-node2 542 
        ctx||202: get-root-node2 545 
        ctx||203: get-root-node2 548 
        ctx||204: get-root-node2 551 
        ctx||205: get-root-node2 554 
        ctx||206: get-root-node2 557 
        ctx||207: get-root-node2 560 
        ctx||208: get-root-node2 563 
        ctx||209: get-root-node2 566 
        ctx||210: get-root-node2 569 
        ctx||211: get-root-node2 572 
        ctx||212: get-root-node2 575 
        ctx||213: get-root-node2 578 
        ctx||214: get-root-node2 581 
        ctx||215: get-root-node2 584 
        ctx||216: get-root-node2 587 
        ctx||217: get-root-node2 590 
        ctx||218: get-root-node2 593 
        ctx||219: get-root-node2 596 
        ctx||220: get-root-node2 599 
        ctx||221: get-root-node2 602 
        ctx||222: get-root-node2 605 
        ctx||223: get-root-node2 608 
        ctx||224: get-root-node2 611 
        ctx||226: get-root-node2 613 
        ctx||228: get-root-node2 614 
        ctx||230: get-root-node2 617 
        ctx||232: get-root-node2 621 
        ctx||234: get-root-node2 623 
        ctx||236: get-root-node2 624 
        ctx||238: get-root-node2 631 
        ctx||240: get-root-node2 634 
        ctx||242: get-root-node2 643 
        ctx||244: get-root-node2 734 
        ctx||246: get-root-node2 739 
        ctx||248: get-root-node2 756 
        ctx||250: get-root-node2 758 
        ctx||252: get-root-node2 760 
        ctx||254: get-root-node2 763 
        ctx||256: get-root-node2 778 
        ctx||258: get-root-node2 779 
        ctx||259: get-root-node2 782 
        ctx||261: get-root-node2 783 
        ctx||263: get-root-node2 786 
        ctx||265: get-root-node2 788 
        ctx||266: get-root-node2 791 
        evt264: as node! 0 
        ctx||267: get-root-node2 794 
        ctx||269: get-root-node2 795 
        ctx||271: get-root-node2 796 
        evt270: as node! 0 
        ctx||272: get-root-node2 799 
        ctx||273: get-root-node2 802 
        evt268: as node! 0 
        ctx||274: get-root-node2 805 
        ctx||276: get-root-node2 806 
        ctx||278: get-root-node2 807 
        ctx||280: get-root-node2 808 
        ctx||282: get-root-node2 809 
        ctx||284: get-root-node2 810 
        ctx||286: get-root-node2 811 
        ctx||288: get-root-node2 812 
        ctx||290: get-root-node2 813 
        ctx||292: get-root-node2 814 
        ctx||294: get-root-node2 817 
        ctx||298: get-root-node2 825 
        ctx||302: get-root-node2 833 
        ctx||306: get-root-node2 841 
        ctx||310: get-root-node2 849 
        ctx||317: get-root-node2 853 
        ctx||318: get-root-node2 856 
        ctx||319: get-root-node2 859 
        ctx||321: get-root-node2 861 
        ctx||322: get-root-node2 864 
        ctx||323: get-root-node2 867 
        ctx||324: get-root-node2 870 
        ctx||325: get-root-node2 873 
        ctx||326: get-root-node2 876 
        ctx||327: get-root-node2 883 
        ctx||328: get-root-node2 886 
        ctx||329: get-root-node2 905 
        ctx||330: get-root-node2 908 
        ctx||331: get-root-node2 919 
        ctx||332: get-root-node2 922 
        ctx||333: get-root-node2 925 
        ctx||334: get-root-node2 928 
        ctx||335: get-root-node2 931 
        ctx||337: get-root-node2 933 
        ctx||338: get-root-node2 936 
        ctx||339: get-root-node2 939 
        ctx||340: get-root-node2 942 
        ctx||341: get-root-node2 945 
        ctx||343: get-root-node2 948 
        ctx||346: get-root-node2 952 
        ctx||347: get-root-node2 955 
        ctx||348: get-root-node2 958 
        ctx||350: get-root-node2 962 
        ctx||351: get-root-node2 965 
        ctx||352: get-root-node2 968 
        ctx||353: get-root-node2 971 
        ctx||354: get-root-node2 974 
        ctx||355: get-root-node2 977 
        ctx||356: get-root-node2 980 
        ctx||357: get-root-node2 983 
        ctx||358: get-root-node2 986 
        ctx||359: get-root-node2 989 
        ctx||360: get-root-node2 992 
        ctx||362: get-root-node2 995 
        ctx||365: get-root-node2 1003 
        ctx||367: get-root-node2 1004 
        evt366: as node! 0 
        ctx||368: get-root-node2 1007 
        ctx||370: get-root-node2 1008 
        evt369: as node! 0 
        ctx||371: get-root-node2 1011 
        ctx||372: get-root-node2 1014 
        ctx||373: get-root-node2 1017 
        ctx||375: get-root-node2 1019 
        ctx||376: get-root-node2 1022 
        ctx||377: get-root-node2 1025 
        ctx||378: get-root-node2 1028 
        ctx||379: get-root-node2 1031 
        ctx||380: get-root-node2 1034 
        ctx||381: get-root-node2 1037 
        ctx||382: get-root-node2 1040 
        ctx||383: get-root-node2 1043 
        ctx||384: get-root-node2 1046 
        ctx||385: get-root-node2 1049 
        ctx||387: get-root-node2 1052 
        ctx||388: get-root-node2 1056 
        ctx||390: get-root-node2 1066 
        ctx||391: get-root-node2 1089 
        ctx||392: get-root-node2 1092 
        ctx||393: get-root-node2 1095 
        ctx||394: get-root-node2 1098 
        ctx||396: get-root-node2 1101 
        ctx||397: get-root-node2 1104 
        ctx||398: get-root-node2 1107 
        ctx||399: get-root-node2 1110 
        ctx||400: get-root-node2 1113 
        ctx||401: get-root-node2 1116 
        ctx||402: get-root-node2 1119 
        ctx||403: get-root-node2 1122 
        ctx||404: get-root-node2 1125 
        ctx||405: get-root-node2 1128 
        ctx||406: get-root-node2 1131 
        ctx||407: get-root-node2 1134 
        ctx||408: get-root-node2 1137 
        ctx||409: get-root-node2 1140 
        ctx||410: get-root-node2 1143 
        ctx||411: get-root-node2 1146 
        ctx||419: get-root-node2 1154 
        ctx||420: get-root-node2 1157 
        ctx||421: get-root-node2 1160 
        ctx||422: get-root-node2 1163 
        ctx||423: get-root-node2 1168 
        ctx||424: get-root-node2 1171 
        ctx||425: get-root-node2 1174 
        ctx||426: get-root-node2 1177 
        ctx||427: get-root-node2 1180 
        ctx||428: get-root-node2 1183 
        ctx||430: get-root-node2 1184 
        ctx||432: get-root-node2 1191 
        ctx||433: get-root-node2 1194 
        ctx||434: get-root-node2 1197 
        ctx||435: get-root-node2 1200 
        ctx||436: get-root-node2 1203 
        ctx||437: get-root-node2 1206 
        ctx||438: get-root-node2 1209 
        ctx||439: get-root-node2 1212 
        ctx||440: get-root-node2 1215 
        ctx||441: get-root-node2 1218 
        ctx||442: get-root-node2 1221 
        ctx||443: get-root-node2 1224 
        ctx||444: get-root-node2 1227 
        ctx||445: get-root-node2 1232 
        ctx||446: get-root-node2 1235 
        ctx||447: get-root-node2 1238 
        ctx||448: get-root-node2 1241 
        ctx||449: get-root-node2 1244 
        ctx||450: get-root-node2 1247 
        ctx||452: get-root-node2 1248 
        ctx||453: get-root-node2 1251 
        evt451: as node! 0 
        ctx||454: get-root-node2 1254 
        ctx||456: get-root-node2 1255 
        ctx||457: get-root-node2 1258 
        evt455: as node! 0 
        ctx||458: get-root-node2 1261 
        ctx||460: get-root-node2 1262 
        evt459: as node! 0 
        ctx||461: get-root-node2 1265 
        ctx||463: get-root-node2 1266 
        evt462: as node! 0 
        ctx||464: get-root-node2 1269 
        ctx||466: get-root-node2 1270 
        ctx||468: get-root-node2 1271 
        ctx||470: get-root-node2 1273 
        ctx||471: get-root-node2 1276 
        ctx||473: get-root-node2 1279 
        ctx||475: get-root-node2 1322 
        ctx||478: get-root-node2 1326 
        ctx||479: get-root-node2 1329 
        ctx||481: get-root-node2 1331 
        ctx||483: get-root-node2 1332 
        ctx||485: get-root-node2 1336 
        ctx||486: get-root-node2 1339 
        ctx||487: get-root-node2 1342 
        ctx||488: get-root-node2 1345 
        ctx||489: get-root-node2 1348 
        ctx||490: get-root-node2 1354 
        ctx||491: get-root-node2 1359 
        ctx||493: get-root-node2 1360 
        ctx||494: get-root-node2 1363 
        ctx||495: get-root-node2 1366 
        ctx||496: get-root-node2 1369 
        ctx||497: get-root-node2 1372 
        ctx||498: get-root-node2 1375 
        ctx||499: get-root-node2 1378 
        ctx||500: get-root-node2 1381 
        ctx||501: get-root-node2 1384 
        ctx||502: get-root-node2 1387 
        ctx||503: get-root-node2 1390 
        ctx||504: get-root-node2 1393 
        ctx||505: get-root-node2 1396 
        ctx||506: get-root-node2 1399 
        ctx||507: get-root-node2 1402 
        ctx||508: get-root-node2 1405 
        ctx||511: get-root-node2 1408 
        ctx||512: get-root-node2 1411 
        ctx||513: get-root-node2 1414 
        ctx||514: get-root-node2 1417 
        ctx||515: get-root-node2 1420 
        ctx||516: get-root-node2 1423 
        ctx||517: get-root-node2 1426 
        ctx||518: get-root-node2 1429 
        ctx||519: get-root-node2 1432 
        ctx||520: get-root-node2 1435 
        ctx||521: get-root-node2 1438 
        ctx||522: get-root-node2 1441 
        ctx||523: get-root-node2 1444 
        ctx||524: get-root-node2 1447 
        ctx||525: get-root-node2 1450 
        ctx||526: get-root-node2 1453 
        ctx||527: get-root-node2 1456 
        ctx||528: get-root-node2 1459 
        ctx||575: get-root-node2 1536 
        ctx||633: get-root-node2 1652 
        ctx||821: get-root-node2 1751
    ] 1201 [%modules/view/view.red] [f_routine #[object! [
            spec: #[none]
            body: #[none]
        ]] ctx||53 [{Defines a function with a given Red spec and Red/System body} spec [block!] body [block!]] f_alert #[object! [
            msg: #[none]
        ]] ctx||54 [msg [block! string!]] f_also #[object! [
            value1: #[none]
            value2: #[none]
        ]] ctx||55 [
            {Returns the first value, but also evaluates the second} 
            value1 [any-type!] 
            value2 [any-type!]
        ] f_attempt #[object! [
            value: #[none]
            safer: #[none]
        ]] ctx||56 [
            {Tries to evaluate a block and returns result or NONE on error} 
            value [block!] 
            /safer "Capture all possible errors and exceptions"
        ] f_comment #[object! [
            value: #[none]
        ]] ctx||57 ["Consume but don't evaluate the next value" 'value] f_quit #[object! [
            return: #[none]
            status: #[none]
        ]] ctx||58 [
            "Stops evaluation and exits the program" 
            /return status [integer!] "Return an exit status"
        ] f_empty? #[object! [
            series: #[none]
        ]] ctx||59 [
            {Returns true if a series is at its tail or a map! is empty} 
            series [map! none! series!] 
            return: [logic!]
        ] f_?? #[object! [
            value: #[none]
        ]] ctx||60 [
            "Prints a word and the value it refers to (molded)" 
            'value [path! word!]
        ] f_probe #[object! [
            value: #[none]
        ]] ctx||61 [
            "Returns a value after printing its molded form" 
            value [any-type!]
        ] f_quote #[object! [
            value: #[none]
        ]] ctx||62 [
            "Return but don't evaluate the next value" 
            :value
        ] f_first #[object! [
            s: #[none]
        ]] ctx||63 ["Returns the first value in a series" s [date! pair! series! time! tuple!]] f_second #[object! [
            s: #[none]
        ]] ctx||64 ["Returns the second value in a series" s [date! pair! series! time! tuple!]] f_third #[object! [
            s: #[none]
        ]] ctx||65 ["Returns the third value in a series" s [date! series! time! tuple!]] f_fourth #[object! [
            s: #[none]
        ]] ctx||66 ["Returns the fourth value in a series" s [date! series! tuple!]] f_fifth #[object! [
            s: #[none]
        ]] ctx||67 ["Returns the fifth value in a series" s [date! series! tuple!]] f_last #[object! [
            s: #[none]
        ]] ctx||68 ["Returns the last value in a series" s [series! tuple!]] f_spec-of #[object! [
            value: #[none]
        ]] ctx||69 [{Returns the spec of a value that supports reflection} value] f_body-of #[object! [
            value: #[none]
        ]] ctx||70 [{Returns the body of a value that supports reflection} value] f_words-of #[object! [
            value: #[none]
        ]] ctx||71 [{Returns the list of words of a value that supports reflection} value] f_class-of #[object! [
            value: #[none]
        ]] ctx||72 ["Returns the class ID of an object" value] f_values-of #[object! [
            value: #[none]
        ]] ctx||73 [{Returns the list of values of a value that supports reflection} value] f_bitset? #[object! [
            value: #[none]
        ]] ctx||74 
        ["Returns true if the value is this type" value [any-type!]] f_binary? #[object! [
            value: #[none]
        ]] ctx||75 
        ["Returns true if the value is this type" value [any-type!]] f_block? #[object! [
            value: #[none]
        ]] ctx||76 
        ["Returns true if the value is this type" value [any-type!]] f_char? #[object! [
            value: #[none]
        ]] ctx||77 
        ["Returns true if the value is this type" value [any-type!]] f_email? #[object! [
            value: #[none]
        ]] ctx||78 
        ["Returns true if the value is this type" value [any-type!]] f_file? #[object! [
            value: #[none]
        ]] ctx||79 
        ["Returns true if the value is this type" value [any-type!]] f_float? #[object! [
            value: #[none]
        ]] ctx||80 
        ["Returns true if the value is this type" value [any-type!]] f_get-path? #[object! [
            value: #[none]
        ]] ctx||81 
        ["Returns true if the value is this type" value [any-type!]] f_get-word? #[object! [
            value: #[none]
        ]] ctx||82 
        ["Returns true if the value is this type" value [any-type!]] f_hash? #[object! [
            value: #[none]
        ]] ctx||83 
        ["Returns true if the value is this type" value [any-type!]] f_integer? #[object! [
            value: #[none]
        ]] ctx||84 
        ["Returns true if the value is this type" value [any-type!]] f_issue? #[object! [
            value: #[none]
        ]] ctx||85 
        ["Returns true if the value is this type" value [any-type!]] f_lit-path? #[object! [
            value: #[none]
        ]] ctx||86 
        ["Returns true if the value is this type" value [any-type!]] f_lit-word? #[object! [
            value: #[none]
        ]] ctx||87 
        ["Returns true if the value is this type" value [any-type!]] f_logic? #[object! [
            value: #[none]
        ]] ctx||88 
        ["Returns true if the value is this type" value [any-type!]] f_map? #[object! [
            value: #[none]
        ]] ctx||89 
        ["Returns true if the value is this type" value [any-type!]] f_none? #[object! [
            value: #[none]
        ]] ctx||90 
        ["Returns true if the value is this type" value [any-type!]] f_pair? #[object! [
            value: #[none]
        ]] ctx||91 
        ["Returns true if the value is this type" value [any-type!]] f_paren? #[object! [
            value: #[none]
        ]] ctx||92 
        ["Returns true if the value is this type" value [any-type!]] f_path? #[object! [
            value: #[none]
        ]] ctx||93 
        ["Returns true if the value is this type" value [any-type!]] f_percent? #[object! [
            value: #[none]
        ]] ctx||94 
        ["Returns true if the value is this type" value [any-type!]] f_refinement? #[object! [
            value: #[none]
        ]] ctx||95 
        ["Returns true if the value is this type" value [any-type!]] f_set-path? #[object! [
            value: #[none]
        ]] ctx||96 
        ["Returns true if the value is this type" value [any-type!]] f_set-word? #[object! [
            value: #[none]
        ]] ctx||97 
        ["Returns true if the value is this type" value [any-type!]] f_string? #[object! [
            value: #[none]
        ]] ctx||98 
        ["Returns true if the value is this type" value [any-type!]] f_tag? #[object! [
            value: #[none]
        ]] ctx||99 
        ["Returns true if the value is this type" value [any-type!]] f_time? #[object! [
            value: #[none]
        ]] ctx||100 
        ["Returns true if the value is this type" value [any-type!]] f_typeset? #[object! [
            value: #[none]
        ]] ctx||101 
        ["Returns true if the value is this type" value [any-type!]] f_tuple? #[object! [
            value: #[none]
        ]] ctx||102 
        ["Returns true if the value is this type" value [any-type!]] f_unset? #[object! [
            value: #[none]
        ]] ctx||103 
        ["Returns true if the value is this type" value [any-type!]] f_url? #[object! [
            value: #[none]
        ]] ctx||104 
        ["Returns true if the value is this type" value [any-type!]] f_word? #[object! [
            value: #[none]
        ]] ctx||105 
        ["Returns true if the value is this type" value [any-type!]] f_image? #[object! [
            value: #[none]
        ]] ctx||106 
        ["Returns true if the value is this type" value [any-type!]] f_date? #[object! [
            value: #[none]
        ]] ctx||107 
        ["Returns true if the value is this type" value [any-type!]] f_money? #[object! [
            value: #[none]
        ]] ctx||108 
        ["Returns true if the value is this type" value [any-type!]] f_ref? #[object! [
            value: #[none]
        ]] ctx||109 
        ["Returns true if the value is this type" value [any-type!]] f_handle? #[object! [
            value: #[none]
        ]] ctx||110 
        ["Returns true if the value is this type" value [any-type!]] f_error? #[object! [
            value: #[none]
        ]] ctx||111 
        ["Returns true if the value is this type" value [any-type!]] f_action? #[object! [
            value: #[none]
        ]] ctx||112 
        ["Returns true if the value is this type" value [any-type!]] f_native? #[object! [
            value: #[none]
        ]] ctx||113 
        ["Returns true if the value is this type" value [any-type!]] f_datatype? #[object! [
            value: #[none]
        ]] ctx||114 
        ["Returns true if the value is this type" value [any-type!]] f_function? #[object! [
            value: #[none]
        ]] ctx||115 
        ["Returns true if the value is this type" value [any-type!]] f_object? #[object! [
            value: #[none]
        ]] ctx||116 
        ["Returns true if the value is this type" value [any-type!]] f_op? #[object! [
            value: #[none]
        ]] ctx||117 
        ["Returns true if the value is this type" value [any-type!]] f_routine? #[object! [
            value: #[none]
        ]] ctx||118 
        ["Returns true if the value is this type" value [any-type!]] f_vector? #[object! [
            value: #[none]
        ]] ctx||119 
        ["Returns true if the value is this type" value [any-type!]] f_any-list? #[object! [
            value: #[none]
        ]] ctx||120 ["Returns true if the value is any type of any-list" value [any-type!]] f_any-block? #[object! [
            value: #[none]
        ]] ctx||121 ["Returns true if the value is any type of any-block" value [any-type!]] f_any-function? #[object! [
            value: #[none]
        ]] ctx||122 [{Returns true if the value is any type of any-function} value [any-type!]] f_any-object? #[object! [
            value: #[none]
        ]] ctx||123 [{Returns true if the value is any type of any-object} value [any-type!]] f_any-path? #[object! [
            value: #[none]
        ]] ctx||124 ["Returns true if the value is any type of any-path" value [any-type!]] f_any-string? #[object! [
            value: #[none]
        ]] ctx||125 [{Returns true if the value is any type of any-string} value [any-type!]] f_any-word? #[object! [
            value: #[none]
        ]] ctx||126 ["Returns true if the value is any type of any-word" value [any-type!]] f_series? #[object! [
            value: #[none]
        ]] ctx||127 ["Returns true if the value is any type of series" value [any-type!]] f_number? #[object! [
            value: #[none]
        ]] ctx||128 ["Returns true if the value is any type of number" value [any-type!]] f_immediate? #[object! [
            value: #[none]
        ]] ctx||129 ["Returns true if the value is any type of immediate" value [any-type!]] f_scalar? #[object! [
            value: #[none]
        ]] ctx||130 ["Returns true if the value is any type of scalar" value [any-type!]] f_all-word? #[object! [
            value: #[none]
        ]] ctx||131 ["Returns true if the value is any type of all-word" value [any-type!]] f_to-bitset #[object! [
            value: #[none]
        ]] ctx||132 ["Convert to bitset! value" value] f_to-binary #[object! [
            value: #[none]
        ]] ctx||133 ["Convert to binary! value" value] f_to-block #[object! [
            value: #[none]
        ]] ctx||134 ["Convert to block! value" value] f_to-char #[object! [
            value: #[none]
        ]] ctx||135 ["Convert to char! value" value] f_to-email #[object! [
            value: #[none]
        ]] ctx||136 ["Convert to email! value" value] f_to-file #[object! [
            value: #[none]
        ]] ctx||137 ["Convert to file! value" value] f_to-float #[object! [
            value: #[none]
        ]] ctx||138 ["Convert to float! value" value] f_to-get-path #[object! [
            value: #[none]
        ]] ctx||139 ["Convert to get-path! value" value] f_to-get-word #[object! [
            value: #[none]
        ]] ctx||140 ["Convert to get-word! value" value] f_to-hash #[object! [
            value: #[none]
        ]] ctx||141 ["Convert to hash! value" value] f_to-integer #[object! [
            value: #[none]
        ]] ctx||142 ["Convert to integer! value" value] f_to-issue #[object! [
            value: #[none]
        ]] ctx||143 ["Convert to issue! value" value] f_to-lit-path #[object! [
            value: #[none]
        ]] ctx||144 ["Convert to lit-path! value" value] f_to-lit-word #[object! [
            value: #[none]
        ]] ctx||145 ["Convert to lit-word! value" value] f_to-logic #[object! [
            value: #[none]
        ]] ctx||146 ["Convert to logic! value" value] f_to-map #[object! [
            value: #[none]
        ]] ctx||147 ["Convert to map! value" value] f_to-none #[object! [
            value: #[none]
        ]] ctx||148 ["Convert to none! value" value] f_to-pair #[object! [
            value: #[none]
        ]] ctx||149 ["Convert to pair! value" value] f_to-paren #[object! [
            value: #[none]
        ]] ctx||150 ["Convert to paren! value" value] f_to-path #[object! [
            value: #[none]
        ]] ctx||151 ["Convert to path! value" value] f_to-percent #[object! [
            value: #[none]
        ]] ctx||152 ["Convert to percent! value" value] f_to-refinement #[object! [
            value: #[none]
        ]] ctx||153 ["Convert to refinement! value" value] f_to-set-path #[object! [
            value: #[none]
        ]] ctx||154 ["Convert to set-path! value" value] f_to-set-word #[object! [
            value: #[none]
        ]] ctx||155 ["Convert to set-word! value" value] f_to-string #[object! [
            value: #[none]
        ]] ctx||156 ["Convert to string! value" value] f_to-tag #[object! [
            value: #[none]
        ]] ctx||157 ["Convert to tag! value" value] f_to-time #[object! [
            value: #[none]
        ]] ctx||158 ["Convert to time! value" value] f_to-typeset #[object! [
            value: #[none]
        ]] ctx||159 ["Convert to typeset! value" value] f_to-tuple #[object! [
            value: #[none]
        ]] ctx||160 ["Convert to tuple! value" value] f_to-unset #[object! [
            value: #[none]
        ]] ctx||161 ["Convert to unset! value" value] f_to-url #[object! [
            value: #[none]
        ]] ctx||162 ["Convert to url! value" value] f_to-word #[object! [
            value: #[none]
        ]] ctx||163 ["Convert to word! value" value] f_to-image #[object! [
            value: #[none]
        ]] ctx||164 ["Convert to image! value" value] f_to-date #[object! [
            value: #[none]
        ]] ctx||165 ["Convert to date! value" value] f_to-money #[object! [
            value: #[none]
        ]] ctx||166 ["Convert to money! value" value] f_to-ref #[object! [
            value: #[none]
        ]] ctx||167 ["Convert to ref! value" value] f_context #[object! [
            spec: #[none]
        ]] ctx||168 [
            "Makes a new object from an evaluated spec" 
            spec [block!]
        ] f_alter #[object! [
            series: #[none]
            value: #[none]
        ]] ctx||169 [
            {If a value is not found in a series, append it; otherwise, remove it. Returns true if added} 
            series [series!] 
            value
        ] f_offset? #[object! [
            series1: #[none]
            series2: #[none]
        ]] ctx||170 [
            "Returns the offset between two series positions" 
            series1 [series!] 
            series2 [series!]
        ] f_repend #[object! [
            series: #[none]
            value: #[none]
            only: #[none]
        ]] ctx||171 [
            {Appends a reduced value to a series and returns the series head} 
            series [series!] 
            value 
            /only "Appends a block value as a block"
        ] f_replace #[object! [
            series: #[none]
            pattern: #[none]
            value: #[none]
            all: #[none]
            deep: #[none]
            case: #[none]
            local: #[none]
            parse?: #[none]
            form?: #[none]
            quote?: #[none]
            deep?: #[none]
            rule: #[none]
            many?: #[none]
            size: #[none]
            seek: #[none]
        ]] ctx||172 [
            "Replaces values in a series, in place" 
            series [any-block! any-string! binary! vector!] "The series to be modified" 
            pattern "Specific value or parse rule pattern to match" 
            value "New value, replaces pattern in the series" 
            /all "Replace all occurrences, not just the first" 
            /deep "Replace pattern in all sub-lists as well" 
            /case "Case-sensitive replacement" 
            /local parse? form? quote? deep? rule many? size seek
        ] f_math #[object! [
            datum: #[none]
            local: #[none]
            match: #[none]
            order: #[none]
            infix: #[none]
            tally: #[none]
            enter: #[none]
            recur: #[none]
            count: #[none]
            operator: #[none]
        ]] ctx||173 [
            "Evaluates expression using math precedence rules" 
            datum [block! paren!] "Expression to evaluate" 
            /local match 
            order infix tally enter recur count operator
        ] f_charset #[object! [
            spec: #[none]
        ]] ctx||174 [
            "Shortcut for `make bitset!`" 
            spec [binary! bitset! block! char! integer! string!]
        ] f_ctx||175~on-parse-event #[object! [
            event: #[none]
            match?: #[none]
            rule: #[none]
            input: #[none]
            stack: #[none]
        ]] ctx||177 [
            "Standard parse/trace callback used by PARSE-TRACE" 
            event [word!] {Trace events: push, pop, fetch, match, iterate, paren, end} 
            match? [logic!] "Result of last matching operation" 
            rule [block!] "Current rule at current position" 
            input [series!] "Input series at next position to match" 
            stack [block!] "Internal parse rules stack" 
            return: [logic!] {TRUE: continue parsing, FALSE: stop and exit parsing}
        ] f_parse-trace #[object! [
            input: #[none]
            rules: #[none]
            case: #[none]
            part: #[none]
            limit: #[none]
        ]] ctx||178 [
            {Wrapper for parse/trace using the default event processor} 
            input [series!] 
            rules [block!] 
            /case "Uses case-sensitive comparison" 
            /part "Limit to a length or position" 
            limit [integer!] 
            return: [logic! block!]
        ] f_suffix? #[object! [
            path: #[none]
        ]] ctx||179 [
            {Returns the suffix (extension) of a filename or url, or NONE if there is no suffix} 
            path [email! file! string! url!]
        ] f_scan #[object! [
            buffer: #[none]
            next: #[none]
            fast: #[none]
        ]] ctx||180 [
            {Returns the guessed type of the first serialized value from the input} 
            buffer [binary! string!] "Input UTF-8 buffer or string" 
            /next {Returns both the type and the input after the value} 
            /fast "Fast scanning, returns best guessed type" 
            return: [datatype! none!] "Recognized or guessed type, or NONE on empty input"
        ] f_load #[object! [
            source: #[none]
            header: #[none]
            all: #[none]
            trap: #[none]
            next: #[none]
            position: #[none]
            part: #[none]
            length: #[none]
            into: #[none]
            out: #[none]
            as: #[none]
            type: #[none]
            local: #[none]
            codec: #[none]
            suffix: #[none]
            name: #[none]
            mime: #[none]
            pre-load: #[none]
        ]] ctx||181 [
            {Returns a value or block of values by reading and evaluating a source} 
            source [binary! file! string! url!] 
            /header "TBD" 
            /all {Load all values, returns a block. TBD: Don't evaluate Red header} 
            /trap "Load all values, returns [[values] position error]" 
            /next {Load the next value only, updates source series word} 
            position [word!] "Word updated with new series position" 
            /part "Limit to a length or position" 
            length [integer! string!] 
            /into {Put results in out block, instead of creating a new block} 
            out [block!] "Target block for results" 
            /as "Specify the type of data; use NONE to load as code" 
            type [none! word!] "E.g. bmp, gif, jpeg, png" 
            /local codec suffix name mime pre-load
        ] f_save #[object! [
            where: #[none]
            value: #[none]
            header: #[none]
            header-data: #[none]
            all: #[none]
            length: #[none]
            as: #[none]
            format: #[none]
            local: #[none]
            dst: #[none]
            codec: #[none]
            data: #[none]
            suffix: #[none]
            find-encoder?: #[none]
            name: #[none]
            pos: #[none]
            header-str: #[none]
            k: #[none]
            v: #[none]
        ]] ctx||182 [
            {Saves a value, block, or other data to a file, URL, binary, or string} 
            where [binary! file! none! string! url!] "Where to save" 
            value [any-type!] "Value(s) to save" 
            /header {Provide a Red header block (or output non-code datatypes)} 
            header-data [block! object!] 
            /all "TBD: Save in serialized format" 
            /length {Save the length of the script content in the header} 
            /as {Specify the format of data; use NONE to save as plain text} 
            format [none! word!] "E.g. bmp, gif, jpeg, png" 
            /local dst codec data suffix find-encoder? name pos header-str k v
        ] f_cause-error #[object! [
            err-type: #[none]
            err-id: #[none]
            args: #[none]
        ]] ctx||183 [
            {Causes an immediate error throw, with the provided information} 
            err-type [word!] 
            err-id [word!] 
            args [block! string!]
        ] f_pad #[object! [
            str: #[none]
            n: #[none]
            left: #[none]
            with: #[none]
            c: #[none]
        ]] ctx||184 [
            "Pad a FORMed value on right side with spaces" 
            str "Value to pad, FORM it if not a string" 
            n [integer!] "Total size (in characters) of the new string" 
            /left "Pad the string on left side" 
            /with "Pad with char" 
            c [char!] 
            return: [string!] "Modified input string at head"
        ] f_mod #[object! [
            a: #[none]
            b: #[none]
            local: #[none]
            r: #[none]
        ]] ctx||185 [
            "Compute a nonnegative remainder of A divided by B" 
            a [char! money! number! pair! time! tuple! vector!] 
            b [char! money! number! pair! time! tuple! vector!] "Must be nonzero" 
            return: [number! money! char! pair! tuple! vector! time!] 
            /local r
        ] f_modulo #[object! [
            a: #[none]
            b: #[none]
            local: #[none]
            r: #[none]
        ]] ctx||186 [
            {Wrapper for MOD that handles errors like REMAINDER. Negligible values (compared to A and B) are rounded to zero} 
            a [char! money! number! pair! time! tuple! vector!] 
            b [char! money! number! pair! time! tuple! vector!] 
            return: [number! money! char! pair! tuple! vector! time!] 
            /local r
        ] f_eval-set-path #[object! [
            value1: #[none]
        ]] ctx||187 ["Internal Use Only" value1] f_to-red-file #[object! [
            path: #[none]
            local: #[none]
            colon?: #[none]
            slash?: #[none]
            len: #[none]
            i: #[none]
            c: #[none]
            dst: #[none]
        ]] ctx||188 [
            {Converts a local system file path to a Red file path} 
            path [file! string!] 
            return: [file!] 
            /local colon? slash? len i c dst
        ] f_dir? #[object! [
            file: #[none]
        ]] ctx||189 [{Returns TRUE if the value looks like a directory spec} file [file! url!]] f_normalize-dir #[object! [
            dir: #[none]
        ]] ctx||190 [
            "Returns an absolute directory spec" 
            dir [file! path! word!]
        ] f_what-dir #[object! [
            local: #[none]
            path: #[none]
        ]] ctx||191 [
            "Returns the active directory path" 
            /local path
        ] f_change-dir #[object! [
            dir: #[none]
        ]] ctx||192 [
            "Changes the active directory path" 
            dir [file! path! word!] {New active directory of relative path to the new one}
        ] f_make-dir #[object! [
            path: #[none]
            deep: #[none]
            local: #[none]
            dirs: #[none]
            end: #[none]
            created: #[none]
            dir: #[none]
        ]] ctx||193 [
            {Creates the specified directory. No error if already exists} 
            path [file!] 
            /deep "Create subdirectories too" 
            /local dirs end created dir
        ] f_extract #[object! [
            series: #[none]
            width: #[none]
            index: #[none]
            pos: #[none]
            into: #[none]
            output: #[none]
        ]] ctx||194 [
            {Extracts a value from a series at regular intervals} 
            series [series!] 
            width [integer!] "Size of each entry (the skip)" 
            /index "Extract from an offset position" 
            pos [integer!] "The position" 
            /into {Provide an output series instead of creating a new one} 
            output [series!] "Output series"
        ] f_extract-boot-args #[object! [
            local: #[none]
            args: #[none]
            at-arg2: #[none]
            ws: #[none]
            buf: #[none]
            s: #[none]
        ]] ctx||195 [
            {Process command-line arguments and store values in system/options (internal usage)} 
            /local args at-arg2 ws buf s
        ] f_collect #[object! [
            body: #[none]
            into: #[none]
            collected: #[none]
            local: #[none]
            keep: #[none]
            rule: #[none]
            pos: #[none]
        ]] ctx||196 [
            {Collect in a new block all the values passed to KEEP function from the body block} 
            body [block!] "Block to evaluate" 
            /into {Insert into a buffer instead (returns position after insert)} 
            collected [series!] "The buffer series (modified)" 
            /local keep rule pos
        ] f_flip-exe-flag #[object! [
            path: #[none]
            local: #[none]
            file: #[none]
            buffer: #[none]
            flag: #[none]
        ]] ctx||197 [
            {Flip the sub-system for the red.exe between console and GUI modes (Windows only)} 
            path [file!] "Path to the red.exe" 
            /local file buffer flag
        ] f_split #[object! [
            series: #[none]
            dlm: #[none]
            local: #[none]
            s: #[none]
            num: #[none]
        ]] ctx||198 [
            {Break a string series into pieces using the provided delimiters} 
            series [any-string!] dlm [bitset! char! string!] /local s 
            num
        ] f_dirize #[object! [
            path: #[none]
        ]] ctx||199 [
            "Returns a copy of the path turned into a directory" 
            path [file! string! url!]
        ] f_clean-path #[object! [
            file: #[none]
            only: #[none]
            dir: #[none]
            local: #[none]
            out: #[none]
            cnt: #[none]
            f: #[none]
            not-file?: #[none]
            prot: #[none]
        ]] ctx||200 [
            {Cleans-up '.' and '..' in path; returns the cleaned path} 
            file [file! string! url!] 
            /only "Do not prepend current directory" 
            /dir "Add a trailing / if missing" 
            /local out cnt f not-file? prot
        ] f_split-path #[object! [
            target: #[none]
            local: #[none]
            dir: #[none]
            pos: #[none]
        ]] ctx||201 [
            {Splits a file or URL path. Returns a block containing path and target} 
            target [file! url!] 
            /local dir pos
        ] f_do-file #[object! [
            file: #[none]
            local: #[none]
            ws: #[none]
            saved: #[none]
            src: #[none]
            code: #[none]
            new-path: #[none]
            header: #[none]
            list: #[none]
            c: #[none]
        ]] ctx||202 ["Internal Use Only" file [file! url!] 
            /local ws saved src code new-path header list c
        ] f_path-thru #[object! [
            url: #[none]
            local: #[none]
            so: #[none]
            hash: #[none]
            file: #[none]
            path: #[none]
        ]] ctx||203 [
            "Returns the local disk cache path of a remote file" 
            url [url!] "Remote file address" 
            return: [file!] 
            /local so hash file path
        ] f_exists-thru? #[object! [
            url: #[none]
        ]] ctx||204 [
            {Returns true if the remote file is present in the local disk cache} 
            url [file! url!] "Remote file address"
        ] f_read-thru #[object! [
            url: #[none]
            update: #[none]
            binary: #[none]
            local: #[none]
            path: #[none]
            data: #[none]
        ]] ctx||205 [
            "Reads a remote file through local disk cache" 
            url [url!] "Remote file address" 
            /update "Force a cache update" 
            /binary "Use binary mode" 
            /local path data
        ] f_load-thru #[object! [
            url: #[none]
            update: #[none]
            as: #[none]
            type: #[none]
            local: #[none]
            path: #[none]
            file: #[none]
        ]] ctx||206 [
            "Loads a remote file through local disk cache" 
            url [url!] "Remote file address" 
            /update "Force a cache update" 
            /as "Specify the type of data; use NONE to load as code" 
            type [none! word!] "E.g. bmp, gif, jpeg, png" 
            /local path file
        ] f_do-thru #[object! [
            url: #[none]
            update: #[none]
        ]] ctx||207 [
            {Evaluates a remote Red script through local disk cache} 
            url [url!] "Remote file address" 
            /update "Force a cache update"
        ] f_cos #[object! [
            angle: #[none]
        ]] ctx||208 [
            "Returns the trigonometric cosine" 
            angle [float!] "Angle in radians"
        ] f_sin #[object! [
            angle: #[none]
        ]] ctx||209 [
            "Returns the trigonometric sine" 
            angle [float!] "Angle in radians"
        ] f_tan #[object! [
            angle: #[none]
        ]] ctx||210 [
            "Returns the trigonometric tangent" 
            angle [float!] "Angle in radians"
        ] f_acos #[object! [
            cosine: #[none]
        ]] ctx||211 [
            {Returns the trigonometric arccosine (in radians in range [0,pi])} 
            cosine [float!] "in range [-1,1]"
        ] f_asin #[object! [
            sine: #[none]
        ]] ctx||212 [
            {Returns the trigonometric arcsine (in radians in range [-pi/2,pi/2])} 
            sine [float!] "in range [-1,1]"
        ] f_atan #[object! [
            tangent: #[none]
        ]] ctx||213 [
            {Returns the trigonometric arctangent (in radians in range [-pi/2,+pi/2])} 
            tangent [float!] "in range [-inf,+inf]"
        ] f_atan2 #[object! [
            y: #[none]
            x: #[none]
        ]] ctx||214 [
            {Returns the smallest angle between the vectors (1,0) and (x,y) in range (-pi,pi]} 
            y [number!] 
            x [number!] 
            return: [float!]
        ] f_sqrt #[object! [
            number: #[none]
        ]] ctx||215 [
            "Returns the square root of a number" 
            number [number!] 
            return: [float!]
        ] f_to-UTC-date #[object! [
            date: #[none]
        ]] ctx||216 [
            "Returns the date with UTC zone" 
            date [date!] 
            return: [date!]
        ] f_to-local-date #[object! [
            date: #[none]
        ]] ctx||217 [
            "Returns the date with local zone" 
            date [date!] 
            return: [date!]
        ] f_transcode-trace #[object! [
            src: #[none]
        ]] ctx||218 [
            {Shortcut function for transcoding while tracing all lexer events} 
            src [binary! string!]
        ] f_rejoin #[object! [
            block: #[none]
        ]] ctx||219 [
            "Reduces and joins a block of values." 
            block [block!] "Values to reduce and join"
        ] f_sum #[object! [
            values: #[none]
            local: #[none]
            result: #[none]
            value: #[none]
        ]] ctx||220 [
            "Returns the sum of all values in a block" 
            values [block! hash! paren! vector!] 
            /local result value
        ] f_average #[object! [
            block: #[none]
        ]] ctx||221 [
            "Returns the average of all values in a block" 
            block [block! hash! paren! vector!]
        ] f_last? #[object! [
            series: #[none]
        ]] ctx||222 [
            "Returns TRUE if the series length is 1" 
            series [series!]
        ] f_dt #[object! [
            body: #[none]
            local: #[none]
            t0: #[none]
        ]] ctx||223 [
            "Returns the time required to evaluate a block" 
            body [block!] 
            return: [time!] 
            /local t0
        ] f_ctx||256~interpreted? #[object! [
        ]] ctx||258 ["Return TRUE if called from the interpreter"] f_ctx||263~on-change* #[object! [
            word: #[none]
            old: #[none]
            new: #[none]
        ]] ctx||265 [word old new] f_ctx||263~on-deep-change* #[object! [
            owner: #[none]
            word: #[none]
            target: #[none]
            action: #[none]
            new: #[none]
            index: #[none]
            part: #[none]
        ]] ctx||266 [owner word target action new index part] f_ctx||269~on-change* #[object! [
            word: #[none]
            old: #[none]
            new: #[none]
        ]] ctx||271 [word old new] f_ctx||267~on-change* #[object! [
            word: #[none]
            old: #[none]
            new: #[none]
        ]] ctx||272 [word old new] f_ctx||267~on-deep-change* #[object! [
            owner: #[none]
            word: #[none]
            target: #[none]
            action: #[none]
            new: #[none]
            index: #[none]
            part: #[none]
        ]] ctx||273 [owner word target action new index part] f_ctx||290~lex #[object! [
            event: #[none]
            input: #[none]
            type: #[none]
            line: #[none]
            token: #[none]
        ]] ctx||292 [
            event [word!] 
            input [binary! string!] 
            type [datatype! none! word!] 
            line [integer!] 
            token 
            return: [logic!]
        ] f_ctx||310~encode #[object! [
            data: #[none]
            where: #[none]
        ]] ctx||317 [data [any-type!] where [file! none! url!]] f_ctx||310~decode #[object! [
            text: #[none]
        ]] ctx||318 [text [binary! file! string!]] f_ctx||319~BOM-UTF-16? #[object! [
            data: #[none]
        ]] ctx||321 [data [binary! string!]] f_ctx||319~BOM-UTF-32? #[object! [
            data: #[none]
        ]] ctx||322 [data [binary! string!]] f_ctx||319~enquote #[object! [
            str: #[none]
        ]] ctx||323 [str [string!] "(modified)"] f_ctx||319~high-surrogate? #[object! [
            codepoint: #[none]
        ]] ctx||324 [codepoint [integer!]] f_ctx||319~low-surrogate? #[object! [
            codepoint: #[none]
        ]] ctx||325 [codepoint [integer!]] f_ctx||319~translit #[object! [
            string: #[none]
            rule: #[none]
            xlat: #[none]
            local: #[none]
            val: #[none]
        ]] ctx||326 [
            "Transliterate sub-strings in a string" 
            string [string!] "Input (modified)" 
            rule [bitset! block!] "What to change" 
            xlat [block! function!] {Translation table or function. MUST map a string! to a string!.} 
            /local val
        ] f_ctx||319~decode-backslash-escapes #[object! [
            string: #[none]
        ]] ctx||327 [string [string!] "(modified)"] f_ctx||319~encode-backslash-escapes #[object! [
            string: #[none]
        ]] ctx||328 [string [string!] "(modified)"] f_ctx||319~decode-unicode-char #[object! [
            ch: #[none]
        ]] ctx||329 [
            {Convert \uxxxx format (NOT simple JSON backslash escapes) to a Unicode char} 
            ch [string!] "4 hex digits"
        ] f_ctx||319~replace-unicode-escapes #[object! [
            s: #[none]
            local: #[none]
            c: #[none]
        ]] ctx||330 [
            s [string!] "(modified)" 
            /local c
        ] f_ctx||319~push #[object! [
            val: #[none]
        ]] ctx||331 [val] f_ctx||319~pop #[object! [
        ]] ctx||332 [] f_ctx||319~emit #[object! [
            value: #[none]
        ]] ctx||333 [value] f_load-json #[object! [
            input: #[none]
        ]] ctx||334 [
            "Convert a JSON string to Red data" 
            input [string!] "The JSON string"
        ] f_ctx||335~init-state #[object! [
            ind: #[none]
            ascii?: #[none]
        ]] ctx||337 [ind ascii?] f_ctx||335~emit-indent #[object! [
            output: #[none]
            level: #[none]
        ]] ctx||338 [output level] f_ctx||335~emit-key-value #[object! [
            output: #[none]
            sep: #[none]
            map: #[none]
            key: #[none]
            local: #[none]
            value: #[none]
        ]] ctx||339 [output sep map key 
            /local value
        ] f_ctx||335~red-to-json-value #[object! [
            output: #[none]
            value: #[none]
            local: #[none]
            special-char: #[none]
            mark1: #[none]
            mark2: #[none]
            escape: #[none]
            v: #[none]
            keys: #[none]
            k: #[none]
        ]] ctx||340 [output value 
            /local special-char mark1 mark2 escape v keys k
        ] f_to-json #[object! [
            data: #[none]
            pretty: #[none]
            indent: #[none]
            ascii: #[none]
            local: #[none]
            result: #[none]
        ]] ctx||341 [
            "Convert Red data to a JSON string" 
            data 
            /pretty indent [string!] "Pretty format the output, using given indentation" 
            /ascii "Force ASCII output (instead of UTF-8)" 
            /local result
        ] f_ctx||343~encode #[object! [
            data: #[none]
            where: #[none]
        ]] ctx||346 [data [any-type!] where [file! none! url!]] f_ctx||343~decode #[object! [
            text: #[none]
        ]] ctx||347 [text [binary! file! string!]] f_ctx||348~to-csv-line #[object! [
            data: #[none]
            delimiter: #[none]
        ]] ctx||350 [
            {Join values as a string and put delimiter between them} 
            data [block!] "Series to join" 
            delimiter [char! string!] "Delimiter to put between values"
        ] f_ctx||348~escape-value #[object! [
            value: #[none]
            delimiter: #[none]
            local: #[none]
            quot?: #[none]
            len: #[none]
        ]] ctx||351 [
            {Escape quotes and when required, enclose value in quotes} 
            value [any-type!] "Value to escape (is formed)" 
            delimiter [char! string!] "Delimiter character to be escaped" 
            /local quot? len
        ] f_ctx||348~next-column-name #[object! [
            name: #[none]
            local: #[none]
            length: #[none]
            index: #[none]
            position: #[none]
            previous: #[none]
        ]] ctx||352 [
            "Return name of next column (A->B, Z->AA, ...)" 
            name [char! string!] "Name of current column" 
            /local length index position previous
        ] f_ctx||348~make-header #[object! [
            length: #[none]
            local: #[none]
            key: #[none]
        ]] ctx||353 [
            "Return default header (A-Z, AA-ZZ, ...)" 
            length [integer!] "Required length of header" 
            /local key
        ] f_ctx||348~get-columns #[object! [
            data: #[none]
            local: #[none]
            columns: #[none]
        ]] ctx||354 [
            "Return all keywords from maps or objects" 
            data [block!] "Data must block of maps or objects" 
            /local columns
        ] f_ctx||348~encode-map #[object! [
            data: #[none]
            delimiter: #[none]
            local: #[none]
            output: #[none]
            keys: #[none]
            length: #[none]
            key: #[none]
            index: #[none]
            line: #[none]
        ]] ctx||355 [
            "Make CSV string from map! of columns" 
            data [map!] "Map of columns" 
            delimiter [char! string!] "Delimiter to use in CSV string" 
            /local output keys length key index line
        ] f_ctx||348~encode-maps #[object! [
            data: #[none]
            delimiter: #[none]
            local: #[none]
            columns: #[none]
            value: #[none]
            line: #[none]
            column: #[none]
        ]] ctx||356 [
            "Make CSV string from block of maps/objects" 
            data [block!] "Block of maps/objects" 
            delimiter [char! string!] "Delimiter to use in CSV string" 
            /local columns value line column
        ] f_ctx||348~encode-flat #[object! [
            data: #[none]
            delimiter: #[none]
            size: #[none]
        ]] ctx||357 [
            "Convert block of fixed size records to CSV string" 
            data [block!] "Block treated as fixed size records" 
            delimiter [char! string!] "Delimiter to use in CSV string" 
            size [integer!] "Size of record"
        ] f_ctx||348~encode-blocks #[object! [
            data: #[none]
            delimiter: #[none]
            local: #[none]
            length: #[none]
            line: #[none]
            csv-line: #[none]
        ]] ctx||358 [
            "Convert block of records to CSV string" 
            data [block!] "Block of blocks, each block is one record" 
            delimiter [char! string!] "Delimiter to use in CSV string" 
            /local length line csv-line
        ] f_load-csv #[object! [
            data: #[none]
            with: #[none]
            delimiter: #[none]
            header: #[none]
            as-columns: #[none]
            as-records: #[none]
            flat: #[none]
            trim: #[none]
            quote: #[none]
            qt-char: #[none]
            local: #[none]
            disallowed: #[none]
            refs: #[none]
            output: #[none]
            out-map: #[none]
            longest: #[none]
            line: #[none]
            value: #[none]
            newline: #[none]
            quotchars: #[none]
            valchars: #[none]
            quoted-value: #[none]
            char: #[none]
            normal-value: #[none]
            s: #[none]
            e: #[none]
            single-value: #[none]
            values: #[none]
            add-value: #[none]
            add-line: #[none]
            length: #[none]
            index: #[none]
            line-rule: #[none]
            init: #[none]
            parsed?: #[none]
            mark: #[none]
            key-index: #[none]
            key: #[none]
        ]] ctx||359 [
            {Converts CSV text to a block of rows, where each row is a block of fields.} 
            data [string!] "Text CSV data to load" 
            /with 
            delimiter [char! string!] "Delimiter to use (default is comma)" 
            /header {Treat first line as header; implies /as-columns if /as-records is not used} 
            /as-columns {Returns named columns; default names if /header is not used} 
            /as-records "Returns records instead of rows; implies /header" 
            /flat {Returns a flat block; you need to know the number of fields} 
            /trim "Ignore spaces between quotes and delimiter" 
            /quote 
            qt-char [char!] {Use different character for quotes than double quote (")} 
            /local disallowed refs output out-map longest line value newline quotchars valchars quoted-value char normal-value s e single-value values add-value add-line length index line-rule init parsed? mark key-index key
        ] f_to-csv #[object! [
            data: #[none]
            with: #[none]
            delimiter: #[none]
            skip: #[none]
            size: #[none]
            quote: #[none]
            qt-char: #[none]
            local: #[none]
            longest: #[none]
            keyval?: #[none]
            types: #[none]
            value: #[none]
        ]] ctx||360 [
            "Make CSV data from input value" 
            data [block! map! object!] {May be block of fixed size records, block of block records, or map columns} 
            /with "Delimiter to use (default is comma)" 
            delimiter [char! string!] 
            /skip "Treat block as table of records with fixed length" 
            size [integer!] 
            /quote 
            qt-char [char!] {Use different character for quotes than double quote (")} 
            /local longest keyval? types value
        ] f_ctx||365~on-change* #[object! [
            word: #[none]
            old: #[none]
            new: #[none]
            local: #[none]
            srs: #[none]
        ]] ctx||367 [word old new 
            /local srs
        ] f_ctx||368~on-deep-change* #[object! [
            owner: #[none]
            word: #[none]
            target: #[none]
            action: #[none]
            new: #[none]
            index: #[none]
            part: #[none]
        ]] ctx||370 [owner word target action new index part] f_reactor #[object! [
            spec: #[none]
        ]] ctx||371 [spec [block!]] f_deep-reactor #[object! [
            spec: #[none]
        ]] ctx||372 [spec [block!]] f_ctx||373~add-relation #[object! [
            obj: #[none]
            word: #[none]
            reaction: #[none]
            targets: #[none]
            local: #[none]
            new-rel: #[none]
        ]] ctx||375 [
            obj [object!] 
            word 
            reaction [block! function!] 
            targets [block! none! object! set-word!] 
            /local new-rel
        ] f_ctx||373~eval #[object! [
            code: #[none]
            safe: #[none]
            local: #[none]
            result: #[none]
        ]] ctx||376 [code [block!] /safe 
            /local result
        ] f_ctx||373~eval-reaction #[object! [
            reactor: #[none]
            reaction: #[none]
            target: #[none]
            mark: #[none]
        ]] ctx||377 [reactor [object!] reaction [block! function!] target /mark] f_ctx||373~pending? #[object! [
            reactor: #[none]
            reaction: #[none]
            local: #[none]
            q: #[none]
        ]] ctx||378 [reactor [object!] reaction [block! function!] 
            /local q
        ] f_ctx||373~check #[object! [
            reactor: #[none]
            only: #[none]
            field: #[none]
            local: #[none]
            pos: #[none]
            reaction: #[none]
            q: #[none]
            q': #[none]
        ]] ctx||379 [reactor [object!] /only field [set-word! word!] 
            /local pos reaction q q'
        ] f_stop-reactor #[object! [
            face: #[none]
            deep: #[none]
            local: #[none]
            list: #[none]
            pos: #[none]
            f: #[none]
        ]] ctx||380 [
            face [object!] 
            /deep 
            /local list pos f
        ] f_clear-reactions #[object! [
        ]] ctx||381 ["Removes all reactive relations"] f_dump-reactions #[object! [
            local: #[none]
            limit: #[none]
            count: #[none]
            obj: #[none]
            field: #[none]
            reaction: #[none]
            target: #[none]
            list: #[none]
        ]] ctx||382 [
            {Output all the current reactive relations for debugging purpose} 
            /local limit count obj field reaction target list
        ] f_ctx||373~is~ #[object! [
            field: #[none]
            reaction: #[none]
            local: #[none]
            obj: #[none]
            rule: #[none]
            item: #[none]
        ]] ctx||383 [
            {Defines a reactive relation whose result is assigned to a word} 
            'field [set-word!] {Set-word which will get set to the result of the reaction} 
            reaction [block!] "Reactive relation" 
            /local obj rule item
        ] f_react? #[object! [
            reactor: #[none]
            field: #[none]
            target: #[none]
            local: #[none]
            pos: #[none]
        ]] ctx||384 [
            {Returns a reactive relation if an object's field is a reactive source} 
            reactor [object!] "Object to check" 
            field [word!] "Field to check" 
            /target "Check if it's a target instead of a source" 
            return: [block! function! word! none!] "Returns reaction, type or NONE" 
            /local pos
        ] f_react #[object! [
            reaction: #[none]
            link: #[none]
            objects: #[none]
            unlink: #[none]
            src: #[none]
            later: #[none]
            with: #[none]
            ctx: #[none]
            local: #[none]
            objs: #[none]
            found?: #[none]
            rule: #[none]
            item: #[none]
            pos: #[none]
            obj: #[none]
            saved: #[none]
            part: #[none]
            path: #[none]
        ]] ctx||385 [
            {Defines a new reactive relation between two or more objects} 
            reaction [block! function!] "Reactive relation" 
            /link "Link objects together using a reactive relation" 
            objects [block!] "Objects to link together" 
            /unlink "Removes an existing reactive relation" 
            src [block! object! word!] "'all word, or a reactor or a list of reactors" 
            /later "Run the reaction on next change instead of now" 
            /with "Specifies an optional face object (internal use)" 
            ctx [none! object! set-word!] "Optional context for VID faces or target set-word" 
            return: [block! function! none!] {The reactive relation or NONE if no relation was processed} 
            /local objs found? rule item pos obj saved part path
        ] f_register-scheme #[object! [
            spec: #[none]
            native: #[none]
            dispatch: #[none]
        ]] ctx||387 [
            "Registers a new scheme" 
            spec [object!] "Scheme definition" 
            /native 
            dispatch [handle!]
        ] f_ctx||388~alpha-num+ #[object! [
            more: #[none]
        ]] ctx||390 [more [string!]] f_ctx||388~parse-url #[object! [
            url: #[none]
            throw-error: #[none]
            local: #[none]
            scheme: #[none]
            user-info: #[none]
            host: #[none]
            port: #[none]
            path: #[none]
            target: #[none]
            query: #[none]
            fragment: #[none]
            ref: #[none]
        ]] ctx||391 [
            {Return object with URL components, or cause an error if not a valid URL} 
            url [string! url!] 
            /throw-error "Throw an error, instead of returning NONE." 
            /local scheme user-info host port path target query fragment ref
        ] f_decode-url #[object! [
            url: #[none]
        ]] ctx||392 [
            {Decode a URL into an object containing its constituent parts} 
            url [string! url!]
        ] f_encode-url #[object! [
            url-obj: #[none]
            local: #[none]
            result: #[none]
        ]] ctx||393 [url-obj [object!] "What you'd get from decode-url" 
            /local result
        ] f_ctx||394~do-quit #[object! [
        ]] ctx||396 [] f_ctx||394~throw-error #[object! [
            error: #[none]
            cmd: #[none]
            code: #[none]
            local: #[none]
            w: #[none]
        ]] ctx||397 [error [error!] cmd [issue!] code [block!] /local w] f_ctx||394~syntax-error #[object! [
            s: #[none]
            e: #[none]
        ]] ctx||398 [s [block! paren!] e [block! paren!]] f_ctx||394~do-safe #[object! [
            code: #[none]
            manual: #[none]
            with: #[none]
            cmd: #[none]
            local: #[none]
            res: #[none]
            t?: #[none]
            src: #[none]
        ]] ctx||399 [code [block! paren!] /manual /with cmd [issue!] /local res t? src] f_ctx||394~do-code #[object! [
            code: #[none]
            cmd: #[none]
            local: #[none]
            p: #[none]
        ]] ctx||400 [code [block! paren!] cmd [issue!] /local p] f_ctx||394~count-args #[object! [
            spec: #[none]
            block: #[none]
            local: #[none]
            total: #[none]
            pos: #[none]
        ]] ctx||401 [spec [block!] /block /local total pos] f_ctx||394~arg-mode? #[object! [
            spec: #[none]
            idx: #[none]
        ]] ctx||402 [spec [block!] idx [integer!]] f_ctx||394~func-arity? #[object! [
            spec: #[none]
            with: #[none]
            path: #[none]
            block: #[none]
            local: #[none]
            arity: #[none]
            pos: #[none]
        ]] ctx||403 [spec [block!] /with path [path!] /block /local arity pos] f_ctx||394~value-path? #[object! [
            path: #[none]
            local: #[none]
            value: #[none]
            i: #[none]
            item: #[none]
            selectable: #[none]
        ]] ctx||404 [path [path!] /local value i item selectable] f_ctx||394~fetch-next #[object! [
            code: #[none]
            local: #[none]
            i: #[none]
            left: #[none]
            item: #[none]
            item2: #[none]
            value: #[none]
            fn-spec: #[none]
            path: #[none]
            f-arity: #[none]
            at-op?: #[none]
            op-mode: #[none]
        ]] ctx||405 [code [block! paren!] /local i left item item2 value fn-spec path f-arity at-op? op-mode] f_ctx||394~eval #[object! [
            code: #[none]
            cmd: #[none]
            local: #[none]
            after: #[none]
            expr: #[none]
        ]] ctx||406 [code [block! paren!] cmd [issue!] /local after expr] f_ctx||394~do-macro #[object! [
            name: #[none]
            pos: #[none]
            arity: #[none]
            local: #[none]
            cmd: #[none]
            saved: #[none]
            p: #[none]
            v: #[none]
            res: #[none]
        ]] ctx||407 [name pos [block! paren!] arity [integer!] /local cmd saved p v res] f_ctx||394~register-macro #[object! [
            spec: #[none]
            local: #[none]
            cnt: #[none]
            rule: #[none]
            p: #[none]
            name: #[none]
            macro: #[none]
            pos: #[none]
            valid?: #[none]
            named?: #[none]
        ]] ctx||408 [spec [block!] /local cnt rule p name macro pos valid? named?] f_ctx||394~reset #[object! [
            job: #[none]
        ]] ctx||409 [job [none! object!]] f_ctx||394~expand #[object! [
            code: #[none]
            job: #[none]
            clean: #[none]
            local: #[none]
            rule: #[none]
            e: #[none]
            pos: #[none]
            cond: #[none]
            value: #[none]
            then: #[none]
            else: #[none]
            cases: #[none]
            body: #[none]
            keep?: #[none]
            expr: #[none]
            src: #[none]
            saved: #[none]
            file: #[none]
        ]] ctx||410 [
            code [block! paren!] job [none! object!] 
            /clean 
            /local rule e pos cond value then else cases body keep? expr src saved file
        ] f_expand-directives #[object! [
            code: #[none]
            clean: #[none]
            local: #[none]
            job: #[none]
        ]] ctx||411 [
            {Invokes the preprocessor on argument list, modifying and returning it} 
            code [block! paren!] "List of Red values to preprocess" 
            /clean "Clear all previously created macros and words" 
            /local job
        ] f_hex-to-rgb #[object! [
            hex: #[none]
            local: #[none]
            str: #[none]
            bin: #[none]
        ]] ctx||419 [
            {Converts a color in hex format to a tuple value; returns NONE if it fails} 
            hex [issue!] "Accepts #rgb, #rrggbb, #rrggbbaa" 
            return: [tuple! none!] 
            /local str bin
        ] f_within? #[object! [
            point: #[none]
            offset: #[none]
            size: #[none]
        ]] ctx||420 [
            {Return TRUE if the point is within the rectangle bounds} 
            point [pair!] "XY position" 
            offset [pair!] "Offset of area" 
            size [pair!] "Size of area" 
            return: [logic!]
        ] f_overlap? #[object! [
            A: #[none]
            B: #[none]
            local: #[none]
            A1: #[none]
            B1: #[none]
            A2: #[none]
            B2: #[none]
        ]] ctx||421 [
            {Return TRUE if the two faces bounding boxes are overlapping} 
            A [object!] "First face" 
            B [object!] "Second face" 
            return: [logic!] "TRUE if overlapping" 
            /local A1 B1 A2 B2
        ] f_distance? #[object! [
            A: #[none]
            B: #[none]
        ]] ctx||422 [
            {Returns the distance between the center of two faces} 
            A [object!] "First face" 
            B [object!] "Second face" 
            return: [float!] "Distance between them"
        ] f_face? #[object! [
            value: #[none]
        ]] ctx||423 [
            value 
            return: [logic!]
        ] f_size-text #[object! [
            face: #[none]
            with: #[none]
            text: #[none]
        ]] ctx||424 [
            face [object!] 
            /with 
            text [string!] 
            return: [pair! none!]
        ] f_caret-to-offset #[object! [
            face: #[none]
            pos: #[none]
            lower: #[none]
            local: #[none]
            opt: #[none]
        ]] ctx||425 [
            face [object!] 
            pos [integer!] 
            /lower 
            return: [pair!] 
            /local opt
        ] f_offset-to-caret #[object! [
            face: #[none]
            pt: #[none]
        ]] ctx||426 [
            face [object!] 
            pt [pair!] 
            return: [integer!]
        ] f_offset-to-char #[object! [
            face: #[none]
            pt: #[none]
        ]] ctx||427 [
            face [object!] 
            pt [pair!] 
            return: [integer!]
        ] f_ctx||430~tail-idx? #[object! [
        ]] ctx||432 [] f_ctx||430~push-color #[object! [
            c: #[none]
        ]] ctx||433 [c [tuple!]] f_ctx||430~pop-color #[object! [
            local: #[none]
            entry: #[none]
            pos: #[none]
        ]] ctx||434 [/local entry pos] f_ctx||430~close-colors #[object! [
            local: #[none]
            pos: #[none]
        ]] ctx||435 [/local pos] f_ctx||430~push #[object! [
            style: #[none]
        ]] ctx||436 [style [block! word!]] f_ctx||430~pop #[object! [
            style: #[none]
            local: #[none]
            entry: #[none]
            type: #[none]
        ]] ctx||437 [style [word!] 
            /local entry type
        ] f_ctx||430~pop-all #[object! [
            mark: #[none]
            local: #[none]
            first?: #[none]
            i: #[none]
        ]] ctx||438 [mark [block!] 
            /local first? i
        ] f_ctx||430~optimize #[object! [
            local: #[none]
            cur: #[none]
            pos: #[none]
            range: #[none]
            pos1: #[none]
            e: #[none]
            s: #[none]
            l: #[none]
            mov: #[none]
        ]] ctx||439 [
            /local cur pos range pos1 e s l mov
        ] f_rtd-layout #[object! [
            spec: #[none]
            only: #[none]
            with: #[none]
            face: #[none]
        ]] ctx||440 [
            "Returns a rich-text face from a RTD source code" 
            spec [block!] "RTD source code" 
            /only "Returns only [text data] facets" 
            /with "Populate an existing face object" 
            face [object!] "Face object to populate" 
            return: [object! block!]
        ] f_ctx||428~line-height? #[object! [
            face: #[none]
            pos: #[none]
        ]] ctx||441 [
            face [object!] 
            pos [integer!] 
            return: [integer!]
        ] f_ctx||428~line-count? #[object! [
            face: #[none]
        ]] ctx||442 [
            face [object!] 
            return: [integer!]
        ] f_metrics? #[object! [
            face: #[none]
            type: #[none]
            total: #[none]
            axis: #[none]
            local: #[none]
            res: #[none]
        ]] ctx||443 [
            face [object!] 
            type [word!] 
            /total 
            axis [word!] 
            /local res
        ] f_set-flag #[object! [
            face: #[none]
            facet: #[none]
            value: #[none]
            local: #[none]
            flags: #[none]
        ]] ctx||444 [
            face [object!] 
            facet [word!] 
            value [any-type!] 
            /local flags
        ] f_debug-info? #[object! [
            face: #[none]
        ]] ctx||445 [face [object!] return: [logic!]] f_on-face-deep-change* #[object! [
            owner: #[none]
            word: #[none]
            target: #[none]
            action: #[none]
            new: #[none]
            index: #[none]
            part: #[none]
            state: #[none]
            forced?: #[none]
            local: #[none]
            faces: #[none]
            face: #[none]
            modal?: #[none]
            pane: #[none]
        ]] ctx||446 [owner word target action new index part state forced? 
            /local faces face modal? pane
        ] f_link-tabs-to-parent #[object! [
            face: #[none]
            init: #[none]
            local: #[none]
            faces: #[none]
            visible?: #[none]
        ]] ctx||447 [
            face [object!] 
            /init 
            /local faces visible?
        ] f_link-sub-to-parent #[object! [
            face: #[none]
            type: #[none]
            old: #[none]
            new: #[none]
            local: #[none]
            parent: #[none]
        ]] ctx||448 [face [object!] type [word!] old new 
            /local parent
        ] f_update-font-faces #[object! [
            parent: #[none]
            local: #[none]
            f: #[none]
        ]] ctx||449 [parent [block! none!] 
            /local f
        ] f_ctx||450~on-change* #[object! [
            word: #[none]
            old: #[none]
            new: #[none]
            local: #[none]
            srs: #[none]
            same-pane?: #[none]
            f: #[none]
            saved: #[none]
        ]] ctx||452 [word old new 
            /local srs same-pane? f saved
        ] f_ctx||450~on-deep-change* #[object! [
            owner: #[none]
            word: #[none]
            target: #[none]
            action: #[none]
            new: #[none]
            index: #[none]
            part: #[none]
        ]] ctx||453 [owner word target action new index part] f_ctx||454~on-change* #[object! [
            word: #[none]
            old: #[none]
            new: #[none]
        ]] ctx||456 [word old new] f_ctx||454~on-deep-change* #[object! [
            owner: #[none]
            word: #[none]
            target: #[none]
            action: #[none]
            new: #[none]
            index: #[none]
            part: #[none]
        ]] ctx||457 [owner word target action new index part] f_ctx||458~on-change* #[object! [
            word: #[none]
            old: #[none]
            new: #[none]
            local: #[none]
            f: #[none]
        ]] ctx||460 [word old new 
            /local f
        ] f_ctx||461~on-change* #[object! [
            word: #[none]
            old: #[none]
            new: #[none]
        ]] ctx||463 [word old new] f_ctx||464~capture-events #[object! [
            face: #[none]
            event: #[none]
            local: #[none]
            result: #[none]
        ]] ctx||470 [face [object!] event [event!] /local result] f_ctx||464~awake #[object! [
            event: #[none]
            with: #[none]
            face: #[none]
            local: #[none]
            result: #[none]
            handler: #[none]
        ]] ctx||471 [event [event!] /with face /local result 
            handler
        ] f_ctx||473~init #[object! [
            local: #[none]
            svs: #[none]
            colors: #[none]
            fonts: #[none]
        ]] ctx||475 [/local svs colors fonts] f_draw #[object! [
            image: #[none]
            cmd: #[none]
            transparent: #[none]
        ]] ctx||478 [
            "Draws scalable vector graphics to an image" 
            image [image! pair!] "Image or size for an image" 
            cmd [block!] "Draw commands" 
            /transparent "Make a transparent image, if pair! spec is used" 
            return: [image!]
        ] f_ctx||483~title-ize #[object! [
            text: #[none]
            local: #[none]
            p: #[none]
        ]] ctx||485 [text [string!] return: [string!] 
            /local p
        ] f_ctx||483~sentence-ize #[object! [
            text: #[none]
            local: #[none]
            h: #[none]
            s: #[none]
            e: #[none]
        ]] ctx||486 [text [string!] return: [string!] 
            /local h s e
        ] f_ctx||483~capitalize #[object! [
            root: #[none]
            local: #[none]
            rule: #[none]
            pos: #[none]
        ]] ctx||487 [
            {Capitalize widget text according to macOS guidelines} 
            root [object!] 
            /local rule pos
        ] f_ctx||483~adjust-buttons #[object! [
            root: #[none]
            local: #[none]
            def-margins: #[none]
            def-margin-yy: #[none]
            opts: #[none]
            class: #[none]
            svmm: #[none]
            y: #[none]
            align: #[none]
            axis: #[none]
            marg: #[none]
            def-marg: #[none]
        ]] ctx||488 [
            {Use standard button classes when buttons are narrow enough} 
            root [object!] 
            /local def-margins def-margin-yy opts class svmm y align axis marg def-marg
        ] f_ctx||483~Cancel-OK #[object! [
            root: #[none]
            local: #[none]
            pos-x: #[none]
            last-but: #[none]
            pos-y: #[none]
            f: #[none]
        ]] ctx||489 [
            "Put OK buttons last" 
            root [object!] 
            /local pos-x last-but pos-y f
        ] f_ctx||481~process #[object! [
            root: #[none]
            local: #[none]
            list: #[none]
            name: #[none]
        ]] ctx||490 [root [object!] 
            /local list name
        ] f_ctx||479~throw-error #[object! [
            spec: #[none]
        ]] ctx||493 [spec [block!]] f_ctx||479~process-reactors #[object! [
            reactors: #[none]
            local: #[none]
            res: #[none]
            f: #[none]
            blk: #[none]
            later?: #[none]
            ctx: #[none]
            face: #[none]
        ]] ctx||494 [reactors [block!] /local res 
            f blk later? ctx face
        ] f_ctx||479~calc-size #[object! [
            face: #[none]
            local: #[none]
            min-sz: #[none]
            data: #[none]
            txt: #[none]
            s: #[none]
            len: #[none]
            mark: #[none]
            e: #[none]
            new: #[none]
        ]] ctx||495 [face [object!] 
            /local min-sz data txt s len mark e new
        ] f_ctx||479~align-faces #[object! [
            pane: #[none]
            dir: #[none]
            align: #[none]
            max-sz: #[none]
            local: #[none]
            edge?: #[none]
            top-left?: #[none]
            axis: #[none]
            svmm: #[none]
            face: #[none]
            offset: #[none]
            mar: #[none]
            type: #[none]
        ]] ctx||496 [pane [block!] dir [word!] align [word!] max-sz [integer!] 
            /local edge? top-left? axis svmm face offset mar type
        ] f_ctx||479~resize-child-panels #[object! [
            tab: #[none]
            local: #[none]
            tp-size: #[none]
            pad: #[none]
            pane: #[none]
        ]] ctx||497 [tab [object!] 
            /local tp-size pad pane
        ] f_ctx||479~clean-style #[object! [
            tmpl: #[none]
            type: #[none]
            local: #[none]
            para: #[none]
            font: #[none]
        ]] ctx||498 [tmpl [block!] type [word!] /local para font] f_ctx||479~process-draw #[object! [
            code: #[none]
            local: #[none]
            rule: #[none]
            pos: #[none]
            color: #[none]
        ]] ctx||499 [code [block!] 
            /local rule pos color
        ] f_ctx||479~pre-load #[object! [
            value: #[none]
            local: #[none]
            color: #[none]
        ]] ctx||500 [value 
            /local color
        ] f_ctx||479~add-option #[object! [
            opts: #[none]
            spec: #[none]
            local: #[none]
            field: #[none]
            value: #[none]
        ]] ctx||501 [opts [object!] spec [block!] 
            /local field value
        ] f_ctx||479~add-flag #[object! [
            obj: #[none]
            facet: #[none]
            field: #[none]
            flag: #[none]
            local: #[none]
            blk: #[none]
        ]] ctx||502 [obj [object!] facet [word!] field [word!] flag return: [logic!] 
            /local blk
        ] f_ctx||479~fetch-value #[object! [
            blk: #[none]
            local: #[none]
            value: #[none]
        ]] ctx||503 [blk 
            /local value
        ] f_ctx||479~fetch-argument #[object! [
            expected: #[none]
            pos: #[none]
            local: #[none]
            spec: #[none]
            type: #[none]
            value: #[none]
        ]] ctx||504 [expected [datatype! typeset!] 'pos [word!] 
            /local spec type value
        ] f_ctx||479~fetch-expr #[object! [
            code: #[none]
        ]] ctx||505 [code [word!]] f_ctx||479~fetch-options #[object! [
            face: #[none]
            opts: #[none]
            style: #[none]
            spec: #[none]
            css: #[none]
            reactors: #[none]
            styling?: #[none]
            no-skip: #[none]
            local: #[none]
            opt?: #[none]
            divides: #[none]
            calc-y?: #[none]
            do-with: #[none]
            obj-spec!: #[none]
            rate!: #[none]
            color!: #[none]
            cursor!: #[none]
            value: #[none]
            match?: #[none]
            drag-on: #[none]
            default: #[none]
            hint: #[none]
            cursor: #[none]
            tight?: #[none]
            later?: #[none]
            max-sz: #[none]
            p: #[none]
            words: #[none]
            user-size?: #[none]
            oi: #[none]
            x: #[none]
            font: #[none]
            face-font: #[none]
            field: #[none]
            actors: #[none]
            name: #[none]
            f: #[none]
            s: #[none]
            b: #[none]
            pad: #[none]
            sz: #[none]
            min-sz: #[none]
            mar: #[none]
        ]] ctx||506 [
            face [object!] opts [object!] style [block!] spec [block!] css [block!] reactors [block!] styling? [logic!] 
            /no-skip 
            return: [block!] 
            /local opt? divides calc-y? do-with obj-spec! rate! color! cursor! value match? drag-on default hint cursor tight? later? max-sz p words user-size? oi x font face-font field actors name f s b pad sz min-sz mar
        ] f_ctx||479~make-actor #[object! [
            obj: #[none]
            name: #[none]
            body: #[none]
            spec: #[none]
        ]] ctx||507 [obj [object!] name [word!] body spec [block!]] f_layout #[object! [
            spec: #[none]
            tight: #[none]
            options: #[none]
            user-opts: #[none]
            flags: #[none]
            flgs: #[none]
            only: #[none]
            parent: #[none]
            panel: #[none]
            divides: #[none]
            styles: #[none]
            css: #[none]
            local: #[none]
            axis: #[none]
            anti: #[none]
            background!: #[none]
            list: #[none]
            reactors: #[none]
            local-styles: #[none]
            pane-size: #[none]
            direction: #[none]
            align: #[none]
            begin: #[none]
            size: #[none]
            max-sz: #[none]
            current: #[none]
            global?: #[none]
            below?: #[none]
            top-left: #[none]
            bound: #[none]
            cursor: #[none]
            origin: #[none]
            spacing: #[none]
            opts: #[none]
            opt-words: #[none]
            re-align: #[none]
            sz: #[none]
            words: #[none]
            reset: #[none]
            focal-face: #[none]
            svmp: #[none]
            pad: #[none]
            value: #[none]
            anti2: #[none]
            at-offset: #[none]
            later?: #[none]
            name: #[none]
            styling?: #[none]
            style: #[none]
            styled?: #[none]
            st: #[none]
            actors: #[none]
            face: #[none]
            h: #[none]
            pos: #[none]
            styled: #[none]
            w: #[none]
            blk: #[none]
            vid-align: #[none]
            mar: #[none]
            divide?: #[none]
            index: #[none]
            dir: #[none]
            pad2: #[none]
            image: #[none]
        ]] ctx||508 [
            {Return a face with a pane built from a VID description} 
            spec [block!] "Dialect block of styles, attributes, and layouts" 
            /tight "Zero offset and origin" 
            /options 
            user-opts [block!] "Optional features in [name: value] format" 
            /flags 
            flgs [block! word!] "One or more window flags" 
            /only "Returns only the pane block" 
            /parent 
            panel [object!] 
            divides [integer! none!] 
            /styles "Use an existing styles list" 
            css [block!] "Styles list" 
            /local axis anti 
            background! list reactors local-styles pane-size direction align begin size max-sz current global? below? top-left bound cursor origin spacing opts opt-words re-align sz words reset focal-face svmp pad value anti2 at-offset later? name styling? style styled? st actors face h pos styled w blk vid-align mar divide? index dir pad2 image
        ] f_do-events #[object! [
            no-wait: #[none]
            local: #[none]
            result: #[none]
            win: #[none]
        ]] ctx||511 [
            /no-wait 
            return: [logic! word!] 
            /local result 
            win
        ] f_stop-events #[object! [
        ]] ctx||512 [] f_do-safe #[object! [
            code: #[none]
            local: #[none]
            result: #[none]
        ]] ctx||513 [code [block!] /local result] f_do-actor #[object! [
            face: #[none]
            event: #[none]
            type: #[none]
            local: #[none]
            result: #[none]
            act: #[none]
            name: #[none]
        ]] ctx||514 [face [object!] event [event! none!] type [word!] /local result 
            act name
        ] f_show #[object! [
            face: #[none]
            with: #[none]
            parent: #[none]
            force: #[none]
            local: #[none]
            show?: #[none]
            f: #[none]
            pending: #[none]
            owner: #[none]
            word: #[none]
            target: #[none]
            action: #[none]
            new: #[none]
            index: #[none]
            part: #[none]
            state: #[none]
            new?: #[none]
            p: #[none]
            obj: #[none]
            field: #[none]
            pane: #[none]
        ]] ctx||515 [
            face [block! object!] 
            /with 
            parent [object!] 
            /force 
            return: [logic!] 
            /local show? f pending owner word target action new index part state new? p obj field pane
        ] f_unview #[object! [
            all: #[none]
            only: #[none]
            face: #[none]
            local: #[none]
            all?: #[none]
            svs: #[none]
            pane: #[none]
        ]] ctx||516 [
            /all 
            /only 
            face [object!] 
            /local all? svs pane
        ] f_view #[object! [
            spec: #[none]
            tight: #[none]
            options: #[none]
            opts: #[none]
            flags: #[none]
            flgs: #[none]
            no-wait: #[none]
        ]] ctx||517 [
            spec [block! object!] 
            /tight 
            /options 
            opts [block!] 
            /flags 
            flgs [block! word!] 
            /no-wait
        ] f_center-face #[object! [
            face: #[none]
            x: #[none]
            y: #[none]
            with: #[none]
            parent: #[none]
            local: #[none]
            pos: #[none]
        ]] ctx||518 [
            face [object!] 
            /x 
            /y 
            /with 
            parent [object!] 
            return: [object!] 
            /local pos
        ] f_make-face #[object! [
            style: #[none]
            spec: #[none]
            blk: #[none]
            offset: #[none]
            xy: #[none]
            size: #[none]
            wh: #[none]
            local: #[none]
            svv: #[none]
            face: #[none]
            styles: #[none]
            model: #[none]
            opts: #[none]
            css: #[none]
        ]] ctx||519 [
            style [word!] 
            /spec 
            blk [block!] 
            /offset 
            xy [pair!] 
            /size 
            wh [pair!] 
            /local 
            svv face styles model opts css
        ] f_dump-face #[object! [
            face: #[none]
            local: #[none]
            depth: #[none]
            f: #[none]
        ]] ctx||520 [
            face [object!] 
            /local depth f
        ] f_get-scroller #[object! [
            face: #[none]
            orientation: #[none]
            local: #[none]
            position: #[none]
            page: #[none]
            min-size: #[none]
            max-size: #[none]
            parent: #[none]
            vertical?: #[none]
        ]] ctx||521 [
            face [object!] 
            orientation [word!] 
            return: [object!] 
            /local position page min-size max-size parent vertical?
        ] f_insert-event-func #[object! [
            fun: #[none]
        ]] ctx||522 [
            fun [block! function!]
        ] f_remove-event-func #[object! [
            fun: #[none]
        ]] ctx||523 [
            fun [function!]
        ] f_request-font #[object! [
            font: #[none]
            ft: #[none]
            mono: #[none]
        ]] ctx||524 [
            /font 
            ft [object!] 
            /mono
        ] f_request-file #[object! [
            title: #[none]
            text: #[none]
            file: #[none]
            name: #[none]
            filter: #[none]
            list: #[none]
            save: #[none]
            multi: #[none]
        ]] ctx||525 [
            /title 
            text [string!] 
            /file 
            name [file! string!] 
            /filter 
            list [block!] 
            /save 
            /multi
        ] f_request-dir #[object! [
            title: #[none]
            text: #[none]
            dir: #[none]
            name: #[none]
            filter: #[none]
            list: #[none]
            keep: #[none]
            multi: #[none]
        ]] ctx||526 [
            /title 
            text [string!] 
            /dir 
            name [file! string!] 
            /filter 
            list [block!] 
            /keep 
            /multi
        ] f_set-focus #[object! [
            face: #[none]
            local: #[none]
            p: #[none]
        ]] ctx||527 [
            face [object!] 
            /local p
        ] f_foreach-face #[object! [
            face: #[none]
            body: #[none]
            with: #[none]
            spec: #[none]
            post: #[none]
            sub: #[none]
            post?: #[none]
            local: #[none]
            exec: #[none]
        ]] ctx||528 [
            face [object!] 
            body [block! function!] 
            /with 
            spec [block! none!] 
            /post 
            /sub post? 
            /local exec
        ] f_keep #[object! [
            v: #[none]
            only: #[none]
        ]] ctx||575 [v /only]
    ]]