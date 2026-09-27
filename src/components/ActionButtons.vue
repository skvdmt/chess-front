<script setup>
const { state, offerDraw } = defineProps(['state', 'offerDraw'])
const emit = defineEmits(['new', 'surrender', 'draw', 'acceptDraw', 'rejectDraw'])
</script>

<template>
  <div class="buttons">
    <button
      v-if="!state.valid &&
      (state.cause == 'white win' ||
        state.cause == 'black win' ||
        state.cause == 'draw')"
      @click="emit('new')"
    >New game</button>
    <button
      v-if="state.valid"
      @click="emit('surrender')"
    >Surrender</button>
    <button
      v-if="state.valid && offerDraw == 0"
      @click="emit('draw')"
    >Offer a draw</button>
    <div v-if="offerDraw > 0" class="offer_draw_dialog">
      <div>Offered a draw</div>
      <div>Your decision:</div>
      <div class="buttons">
        <button class="accept" @click="emit('acceptDraw')">accept</button>
        <button class="reject" @click="emit('rejectDraw')">reject</button>
        <div class="timer">{{ offerDraw }}</div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.buttons {
  display: flex;
  align-items: flex-start;
  flex-wrap: wrap;
  gap: 10px;
  @media (max-width: 768px) {
    justify-content: center;
  }
  button {
    font-family: "OpenSans-Regular";
    border-radius: 10px;
    white-space: nowrap;
    padding: 10px;
    background-color: teal;
    border: 2px solid teal;
    color: white;
    font-size: 17px;
  }
  button:hover{
    background-color: white;
    color: teal;
  }
  .offer_draw_dialog {
    display: flex;
    flex-direction: column;
    gap: 5px;
    padding: 5px;
    border: 1px solid black;
    background-color: white;
    border-radius: 5px;
    .buttons {
      display: flex;
      align-items: stretch;
      gap: 5px;
      .reject {
        background-color: red;
        border-color: red;
      }
      .reject:hover {
        background-color: white;
        color: red;
      }
      .timer {
        align-content: center;
        font-size: 24px;
        color: red;
        border-radius: 10px;
        padding: 10px;
      }
    }
  }
}
</style>
