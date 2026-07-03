<script setup>
import { defineProps } from 'vue'
import StatClock from './StatClock.vue';
import StatState from './StatState.vue';
const { team, turn, clock, state } = defineProps(['team', 'turn', 'clock', 'state'])
</script>

<template>
  <div class="stat">
    <div class="wrapper">
      <StatClock
        :clock="clock"
      />
      <StatState
        :team="team"
        :turn="turn"
        :state="state"
      />
    </div>
  </div>
</template>

<style scoped>
  .stat {
    min-width: 200px;
    min-height: 100px;
    /* background-color: aqua; */
    text-align: left;
    .wrapper {
      padding: 10px;
      @media (max-width: 439px) {
        padding: 5px;
      }
    }
    .wrapper {
      display: flex;
      gap: 10px;
      align-items: flex-start;
      @media (max-width: 768px) {
        justify-content: space-between;
      }
      @media (max-width: 439px) {
        gap: 5px;
      }
    }
  }
</style>
