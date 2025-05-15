function addLaplaceNoise(value, epsilon) {
    const scale = 1 / epsilon;
    const u = Math.random() - 0.5;
    const noise = -scale * Math.sign(u) * Math.log(1 - 2 * Math.abs(u));
    return value + noise;
}

module.exports = { addLaplaceNoise };