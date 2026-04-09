return {

    useScheduledWeather = true, -- Thunderstorms will be scheduled near restart
    serverDuration = 14, -- How many hours will the server run before restarting?
    weatherCycletimer = 30, -- How many minutes between weather changes

    timeBetweenRain = 180, -- How many minutes between rain events
    rainAfterRestart = 60, -- How many minutes AFTER a server restart before rain will start to show?

    decemberSnow = false, -- Disabled snow for December

    useStaticWeather = false,
    staticWeather = {
        ['BLIZZARD'] = 0.0,
        ['CLEAR'] = 0.0,
        ['CLEARING'] = 0.0,
        ['CLOUDS'] = 0.0,
        ['EXTRASUNNY'] = 1.0,
        ['FOGGY'] = 0.0,
        ['NEUTRAL'] = 0.0,
        ['OVERCAST'] = 0.0,
        ['RAIN'] = 0.0,
        ['SMOG'] = 0.0,
        ['SNOW'] = 0.0,
        ['SNOWLIGHT'] = 0.0,
        ['THUNDER'] = 0.0,
        ['XMAS'] = 0.0
    },

    useWeatherSequences = true,

    weatherSequences = {

        { -- Sunny all the time
            probability = 1.0, -- 100%
            events = {
                {
                    weather = 'EXTRASUNNY',
                    time = 30, -- Minutes
                    windSpeed = 0.05,
                }
            },
        },
    }
}
