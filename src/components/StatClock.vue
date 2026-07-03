<script setup>
const { clock } = defineProps(['clock'])

function TimeConvert(num) {
  num = num / 1000 / 1000 / 1000
  var m = Math.floor(num / 60)
  var s = num % 60
  if (s.toString().length == 1) {
    return m + ":0" + s
  }
  return m + ":" + s
}

function TimeColor(num) {
  num = num / 1000 / 1000 / 1000
  if (num <= 10) {
    return 'warn'
  }
  return ''
}
</script>

<template>
  <div class="clock">
    <div class="step" :class="TimeColor(clock.turn_step)">{{ TimeConvert(clock.turn_step) }}</div>
    <div class="reserve">
      <div>reserve:</div>
      <div>white: <span>{{ TimeConvert(clock.white_reserve) }}</span></div>
      <div>black: <span>{{ TimeConvert(clock.black_reserve) }}</span></div>
    </div>
  </div>
</template>

<style scoped>
.clock {
  /* background-color: antiquewhite; */
  .step {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 10px;
    white-space: nowrap;
    background-color: olivedrab;
    color: white;
    font-size: 36px;
    @media (max-width: 768px) {
      font-size:28px;
    }
  }
  .step.warn {
    background-color: red;
    color: white;
  }
  .reserve {
    padding: 0 5px;
  }
}
</style>
