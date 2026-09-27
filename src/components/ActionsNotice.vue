<script setup>
const { notice } = defineProps(['notice'])

function NoticeClass() {
  if (notice.length > 0) {
    return 'draw'
  }
}

function Notice() {
  if (notice == "black win" ||
    notice == "white win" ||
    notice == "draw") {
    return 'game over'
  }
  return notice
}
</script>

<template>
  <div class="notice" :class="NoticeClass()">{{ Notice() }}</div>
</template>

<style scoped>
.notice {
  line-height: 2em;
  color: white;
  border-radius: 10px;
  font-size: 24px;
  min-height: 48px;
  @media (max-width: 768px) {
    font-size:18px;
    min-height: 36px;
  }
}
.notice.draw {
  background-color: red;
  opacity: 0;
  transition-delay: 4s;
  transition-duration: 1s;
  transition-property: opacity;
}
</style>
