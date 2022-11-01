local inspect = require('inspect');

local dial = function (context, extension)
    app.noop("context: " .. context .. ", extension: " .. extension);
    app.dial('PJSIP/' .. extension, 10);
    
    local dialstatus = channel["DIALSTATUS"]:get();
    app.noop('dialstatus: '..dialstatus);
    app.set("CHANNEL(language)=ru");

    if dialstatus == 'BUSY' then
        app.playback("followme/sorry");        
    elseif dialstatus == 'CHANUNAVAIL' then 
        app.playback("followme/sorry");
    end;

    app.hangup();
end;

local ivr = function (context, extension)        
    local v = '1'
    app.noop('lolo:'..inspect(v));
    app.read("IVR_CHOOSE", "/var/menu/demo", 1, nil, 2, 3);
    local choose = channel["IVR_CHOOSE"]:get();

    if choose == '1' then
        app.queue('1234');
    elseif choose == '2' then
        dial('internal', '101');
    else
        app.hangup();
    end;
end;

extensions = {
    ["internal"] = {

        ["*12"] = function ()
            app.sayunixtime();
        end;

        ["_1XX"] = dial;

        ["200"] = ivr;

        ["_XXXXXXXXXXX"] = function(context, extension)
            app.dial('PJSIP/'..extension..'@sipnet.ru');
        end;

        ["h"] = function()
            local dialstatus = channel["DIALSTATUS"]:get();
            app.noop('DIALSTATUS: '..tostring(dialstatus));
            app.noop('hangup!')
        end;
    };
};

hints = {};