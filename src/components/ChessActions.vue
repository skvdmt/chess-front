<script setup>
import ActionButtons from './ActionButtons.vue';
import ActionsNotice from './ActionsNotice.vue';

const { state, notice, offerDraw } = defineProps(['state', 'notice', 'offerDraw'])
const emit = defineEmits(['new', 'surrender', 'draw', 'acceptDraw', 'rejectDraw'])
</script>

<template>
  <div class="actions">
    <div class="wrapper">
      <ActionButtons
        @new="emit('new')"
        @surrender="emit('surrender')"
        @draw="emit('draw')"
        @acceptDraw="emit('acceptDraw')"
        @rejectDraw="emit('rejectDraw')"
        :state="state"
        :offerDraw="offerDraw"
      />
      <ActionsNotice
        :notice="notice"
      />
    </div>
  </div>
</template>

<style scoped>
.actions {
  min-width: 200px;
  min-height: 100px;
  /* background-color: orange; */
  .wrapper {
    padding: 10px;
    display: flex;
    /* align-items: flex-start; */
    flex-direction: column;
    @media (max-width: 768px) {
      flex-direction: column-reverse;
    }
    gap: 10px;
  }
}
</style>
