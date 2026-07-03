<script setup>
import { computed, defineProps } from 'vue'
const { team, turn, state } = defineProps(['team', 'turn', 'state'])

const State = computed(() => {
  if (state.valid) {
    return 'played'
  }
  if (state.cause == 'White Win' ||
    state.cause == 'Black Win' ||
    state.cause == 'Draw') {
      return 'over'
  }
  return 'paused'
})

function stateClass() {
  if (!state.valid) {
    return 'fail'
  }
  return 'success'
}

function TurnColor() {
  if (state.cause == 'White Win' ||
    state.cause == 'Black Win' ||
    state.cause == 'Draw') {
      return 'red'
  }
  if (state.valid && turn == team) {
    return 'your'
  }
  return ''
}

function TurnContent() {
  if (state.cause == 'White Win' ||
    state.cause == 'Black Win' ||
    state.cause == 'Draw') {
      return state.cause
  }
  if (team == turn) {
    return 'Your turn'
  }
  return turn + ' turn'
}
</script>

<template>
  <div class="turn" :class="TurnColor(turn)">{{ TurnContent() }}</div>
  <div class="state">
    <div class="team">team: <span class="name" :class="team">{{ team }}</span></div>
    <div><span class="state" :class="stateClass()">Game {{ State }}</span></div>
    <div class="cause">{{ state.cause }}</div>
  </div>
</template>

<style scoped>
  .turn {
    /* display: inline-block; */
    /* white-space: nowrap; */
    text-align: center;
    max-width: 100px;
    font-size: 24px;
    background-color: gray;
    border-radius: 20px;
    padding: 15px 5px;
    color: white;
    text-transform: uppercase;
    @media (max-width: 768px) {
      font-size:18px;
      font-weight: 600;
    }
  }
  .turn.your {
    background-color: green;
  }
  .turn.red {
    background-color: red;
  }
.state{
  /* background-color: brown; */
  .team {
    white-space: nowrap;
    line-height: 2em;
    font-size: 16px;
    .name {
      border: 1px solid gray;
      background-color: gray;
      color: white;
      border-radius: 10px;
      padding: 3px 5px;
      text-transform: uppercase;
    }
    .name.white{
      border: 1px solid black;
      background-color: white;
      color: black;
    }
    .name.black{
      border: 1px solid black;
      background-color: black;
      color: white;
    }
  }
  .state {
    white-space: nowrap;
    border-radius: 10px;
    padding: 3px 5px;
    color: white;
    line-height: 2em;
    font-size: 16px;
  }
  .state.success {
    background-color: yellowgreen;
  }
  .state.fail {
    background-color: red;
  }
  .cause {
    min-height: 19.2px;
    text-transform: lowercase;
    line-height: 1.2em;
    font-style: italic;
    font-size: 16px;
    @media (max-width: 439px) {
      font-size:13px;
    }
  }
}
</style>
