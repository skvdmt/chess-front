<script setup>
import { ref, defineProps, computed } from 'vue'

const emit = defineEmits(['move'])

const { boardData, team, lastMove } = defineProps(['boardData', 'team', 'lastMove'])

const maxX = 10
const maxY = 10

const letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']

// Перерасчет фигур на доске.
const board = computed(() => {
  if (!boardData || !boardData.white || !boardData.black) {
    return []
  } else {
    const b = []
    for (let y = 1; y <= 8; y++) {
      for (let x = 1; x <= 8; x++) {
        let f = false
        boardData.white.on_board_chess_pieces.forEach(e => {
          if (e.position.x == x && e.position.y == y) {
            b.push({
              team: "white",
              name: e.name,
            })
            f = true
            return
          }
        })
        if (f) {
          continue
        }
        boardData.black.on_board_chess_pieces.forEach(e => {
          if (e.position.x == x && e.position.y == y) {
            b.push({
              team: "black",
              name: e.name,
            })
            f = true
            return
          }
        })
        if (f) {
          continue
        }
        b.push(undefined)
      }
    }
    return b
  }
})

// Фон ячейки доски.
function BackgroundCol(x, y, lastMove) {
  if (x == 1 || x == 10 || y == 1 || y == 10) {
    return ''
  }
  if (x % 2 == y % 2) {
    if ((x == lastMove.from.x+1 && y == lastMove.from.y+1) ||
      (x == lastMove.to.x+1 && y == lastMove.to.y+1) ) {
        return 'dark last'
    }
    return 'dark'
  }
  if ((x == lastMove.from.x+1 && y == lastMove.from.y+1) ||
    (x == lastMove.to.x+1 && y == lastMove.to.y+1) ) {
      return 'light last'
  }
  return 'light'
}

// Объект совершения хода.
const Move = ref({
  from: {
    x: 0,
    y: 0,
  },
  to: {
    x: 0,
    y: 0,
  }
})

// Шахматная фигура выбрана.
Move.ChessPieceSelected = function() {
  return this.value.from.x > 0
}

// Конечная точка хода совпадает с изначальной.
Move.FromEqualTo = function() {
  return this.value.from.x == this.value.to.x && this.value.from.y == this.value.to.y
}

// Сброс хода.
Move.Reset = function() {
  this.value = {from: {x: 0, y: 0}, to: {x: 0, y: 0}}
}

let HighLightTarget;

// Нажатие на доску.
function Click(x, y, e) {
  if (!OnBoard(x, y)) {
    return
  }
  // Выбор фигуры
  if (!Move.ChessPieceSelected()) {
    if (ExistYourChessPiece(x, y)) {
      Move.value.from = {x: x, y: y}
      console.log('take chess piece.')
      // Смена фона.
      if (e.target.classList.contains('chess-piece')) {
        HighLightTarget = e.target.parentElement
      } else {
        HighLightTarget = e.target
      }
      HighLightTarget.classList.add('take')
    }
    return
  }
  // Выбор конечной точки
  HighLightTarget.classList.remove('take')
  HighLightTarget = undefined
  // Выбор конечной точки хода.
  Move.value.to = {x: x, y: y}
  // Конечная точка хода совпадает с изначальной
  // Поставить фигуру на место.
  if (Move.FromEqualTo()) {
    Move.Reset()
    return
  }
  // Отправить ход.
  emit('move', Move.value)
  Move.Reset()
}

// Позиция на доске.
function OnBoard(x, y) {
  if (x < 1 || x > 8 || y < 1 || y > 8) {
    return false
  }
  return true
}

// На позиции есть фигура.
function OnChessPiece(x, y) {
  const i = 8*(y-1)+x-1
  if (board.value[i] === undefined) {
    return false
  }
  return true
}

// Есть фигура вашей команды.
function ExistYourChessPiece(x, y) {
  const i = 8*(y-1)+x-1
  if (board.value[i] === undefined) {
    return false
  }
  if (board.value[i].team !== team) {
    return false
  }
  return true
}

// Нарисовать фигуру.
function DrawChessPiece(x, y) {
  const i = 8*(y-1)+x-1
  if (board.value[i] !== undefined) {
    return board.value[i].team + " " + board.value[i].name
  }
}

</script>

<template>
  <div id="board" class="board" :class="team">
    <div class="row" v-for="y in maxY">
      <div class="col"
        :class="BackgroundCol(x, y, lastMove)"
        v-for="x in maxX"
        @click="Click(x-1,y-1, $event)"
      >
      <div class="chess-piece" :class="DrawChessPiece(x-1,y-1)"
        v-if="OnBoard(x-1,y-1) && OnChessPiece(x-1,y-1)"></div>
      <span class="title number" 
        v-if="(y == 1 || y == 10) && x > 1 && x < 10">{{ letters[x-2] }}</span>
      <span class="title letter"
        v-if="(x == 1 || x == 10) && y > 1 && y < 10">{{ y-1 }}</span>
      </div>
    </div>
  </div>
</template>

<style scoped>
.board.black {
  flex-direction: column;
}
.board {
  aspect-ratio : 1 / 1;
  margin: 0 auto;
  min-width: 300px;
  max-width: 500px;
  width: 100%;
  /* background-color: red; */
  display: flex;
  flex-direction: column-reverse;
  @media (max-width: 768px) {
    max-width: none;
  }
  .row {
    display: flex;
    flex-direction: row;
    flex-grow: 1;
    flex-shrink: 1;
    height: 10%;
    .col {
      display: flex;
      align-items: center;
      justify-content: center;
      flex-grow: 1;
      flex-shrink: 1;
      width: 10%;
      background-color: white;
      .title {
        -webkit-touch-callout: none;
        -webkit-user-select: none;
        -khtml-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
      }
      .title.number {
        font-size: 15px;
      }
      .title.letter {
        font-size: 17px;
      }
      .chess-piece {
        width: 100%;
        align-self: stretch;
        padding: 0;
        background-position: center center;
        background-repeat: no-repeat;
        background-size: contain;
        background-origin: content-box;
      }
      .chess-piece.white.pawn{
        background-image: url('@/assets/white/pawn.svg');
      }
      .chess-piece.white.rook{
        background-image: url('@/assets/white/rook.svg');
      }
      .chess-piece.white.knight{
        background-image: url('@/assets/white/knight.svg');
      }
      .chess-piece.white.bishop{
        background-image: url('@/assets/white/bishop.svg');
      }
      .chess-piece.white.king{
        background-image: url('@/assets/white/king.svg');
      }
      .chess-piece.white.queen{
        background-image: url('@/assets/white/queen.svg');
      }
      .chess-piece.black.pawn{
        background-image: url('@/assets/black/pawn.svg');
      }
      .chess-piece.black.rook{
        background-image: url('@/assets/black/rook.svg');
      }
      .chess-piece.black.knight{
        background-image: url('@/assets/black/knight.svg');
      }
      .chess-piece.black.bishop{
        background-image: url('@/assets/black/bishop.svg');
      }
      .chess-piece.black.king{
        background-image: url('@/assets/black/king.svg');
      }
      .chess-piece.black.queen{
        background-image: url('@/assets/black/queen.svg');
      }
    }
    .col.light {
      background-color: #ffce9e;
    }
    .col.dark {
      background-color: #d18b47;
    }
    .col.light.take {
      background-color: #ceff9e;
    }
    .col.dark.take {
      background-color: #8bd147;
    }
    .col.light.last {
      background-color: #9eceff;
    }
    .col.dark.last {
      background-color: #478bd1;
    }
  }
}
.board.cursor-white-rook {
  cursor: url('@/assets/white/rook.svg') 22 22, pointer;
}
</style>