// Enemy commander: a dependable loop, not a clever one.
//   income -> produce (rotation) -> assemble at rally -> attack when the wave timer fires
//   -> the wave marches on the player fortress -> repeat, one unit bigger each time.
// Pure functions over an `ai` state object; the game supplies a `world` adapter:
//   world.time, world.enemyUnits (alive, not in a wave -> "garrison"), world.canProduce(typeId),
//   world.produce(typeId), world.launchWave(unitList, targetBuilding), world.playerFortress
.pragma library
.import "Economy.js" as Economy
.import "../config/balance.js" as Balance

function create(cfg, difficultyName) {
    var d = Balance.difficultyFor(difficultyName)
    return {
        economy: Economy.create(cfg.startIron),
        incomePerSecond: cfg.passiveIncomePerSecond * d.incomeScale,
        nextWaveAt: cfg.firstWaveDelay * (d.firstWaveDelayScale || 1),
        waveInterval: d.waveInterval,
        waveGrowth: d.waveGrowth,
        wavesLaunched: 0,
        productionIndex: 0,
        state: "building",            // building | assembling | attacking (label for HUD/tests)
        lastProduceAttempt: -99,
        log: []
    }
}

function nextType(ai, cfg) {
    var wave = ai.wavesLaunched + 1
    // an ogre joins every Nth wave: queue it once per such wave when affordable
    if (cfg.ogreEveryNthWave && wave % cfg.ogreEveryNthWave === 0 && !ai.ogreQueuedForWave) {
        if (Economy.canAfford(ai.economy, Balance.units.ironhide_ogre.cost)) {
            ai.ogreQueuedForWave = wave
            return "ironhide_ogre"
        }
    }
    var t = cfg.productionOrder[ai.productionIndex % cfg.productionOrder.length]
    ai.productionIndex++
    return t
}

function waveSize(ai, cfg) {
    return Math.min(cfg.waveMaxSize, cfg.waveBaseSize + ai.wavesLaunched * ai.waveGrowth)
}

function step(ai, dt, cfg, world) {
    Economy.deposit(ai.economy, ai.incomePerSecond * dt)
    ai.economy.gathered -= ai.incomePerSecond * dt        // passive income is not "gathered"

    // produce whenever affordable and the foundry is free; keep at most one item queued
    if (world.time - ai.lastProduceAttempt >= 1.0) {
        ai.lastProduceAttempt = world.time
        var t = nextType(ai, cfg)
        if (Economy.canAfford(ai.economy, Balance.units[t].cost) && world.canProduce(t)) {
            Economy.spend(ai.economy, Balance.units[t].cost)
            world.produce(t)
        }
    }

    var idle = world.enemyUnits            // garrison + assembling units
    var target = waveSize(ai, cfg)
    ai.state = idle.length >= target ? "assembling" : "building"

    // launch: timer elapsed and enough bodies beyond the garrison minimum
    var available = Math.max(0, idle.length - cfg.garrisonMin)
    if (world.time >= ai.nextWaveAt && available >= Math.max(1, Math.min(target, available))) {
        var send = idle.slice(0, Math.max(1, Math.min(target, available)))
        if (send.length > 0 && world.playerFortress) {
            world.launchWave(send, world.playerFortress)
            ai.wavesLaunched++
            ai.ogreQueuedForWave = 0
            ai.nextWaveAt = world.time + ai.waveInterval
            ai.state = "attacking"
            ai.log.push({ time: world.time, size: send.length })
        }
    } else if (world.time >= ai.nextWaveAt) {
        // not enough units yet: retry shortly rather than waiting a full interval
        ai.nextWaveAt = world.time + 8
    }
}
