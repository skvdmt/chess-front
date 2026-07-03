<script setup>
import { onMounted, watch, ref } from 'vue';
import ChessBoard from './components/ChessBoard.vue';
import ChessStat from './components/ChessStat.vue';
import ChessActions from './components/ChessActions.vue';

const TIMEOUT = 5000
const NOTICE_DISPLAY = 5000
const callbacks = []
const REQUEST_GET_BOARD = 'GET_BOARD'
const REQUEST_GET_TEAM_NAME = 'GET_TEAM_NAME'
const REQUEST_GET_TURN = 'GET_TURN'
const REQUEST_GET_STATUS = 'GET_STATUS'
const REQUEST_GET_CLOCK = 'GET_CLOCK'
const REQUEST_POST_MOVE = 'POST_MOVE'
const REQUEST_POST_NEW_GAME = 'POST_NEW_GAME'
const REQUEST_POST_SURRENDER = 'POST_SURRENDER'
const REQUEST_POST_OFFER_A_DRAW = 'POST_OFFER_A_DRAW'
const	REQUEST_POST_ACCEPT_DRAW = 'POST_ACCEPT_DRAW'
const	REQUEST_POST_REJECT_DRAW = 'POST_REJECT_DRAW'

const lastMove = ref({
  from: {x: 0, y: 0},
  to: {x: 0, y: 0}
})
const boardData = ref()
const team = ref()
const turn = ref()
const clock = ref({
  turn_step: 0,
  white_reserve: 0,
  black_reserve: 0,
})
const state = ref({
  valid: false,
  cause: '',
})
const offerDraw = ref(0)

let pass

const ws = new WebSocket('wss://chess.skvdmt.ru/connect')

// Отправка запроса.
function Send(req, callback) {
  req.id = crypto.randomUUID()
  const timer = setTimeout(() => {
    if (callbacks[req.id]) {
      console.log(`Request ${req.id} timeout.`)
      delete callbacks[req.id]
    }
  }, TIMEOUT)
  callbacks[req.id] = {callback, timer}
  ws.send(JSON.stringify(req))
}

// Запрос стартовой информации.
function GetStartInfo() {
  Send({method: REQUEST_GET_BOARD}, (response) => {
    boardData.value = response.body
  })
  Send({method: REQUEST_GET_TEAM_NAME}, (response) => {
    team.value = response.body.name
  })
  Send({method: REQUEST_GET_TURN}, (response) => {
    turn.value = response.body.name
  })
  Send({method: REQUEST_GET_CLOCK}, (response) => {
    clock.value = response.body
  })
  Send({method: REQUEST_GET_STATUS}, (response) => {
    state.value = response.body
  })
}

// Обработчик события создания.
function EventCreatedHandler() {
  GetStartInfo()
  // Обнуление последнего хода.
  lastMove.value = {
    from: {x: 0, y: 0},
    to: {x: 0, y: 0}
  }
}

// Обработчик события часов.
function EventClockHandler(data) {
  if (data.turn_step == 0) {
    clock.value.turn_step = data.turn_reserve
  } else {
    clock.value.turn_step = data.turn_step
  }
  switch (turn.value) {
    case "white":
      clock.value.white_reserve = data.turn_reserve
      break
    case "black":
      clock.value.black_reserve = data.turn_reserve
      break
  }
}

// Обработчик события хода.
function EventMoveHandler(data) {
  // Последний ход.
  lastMove.value = data.body
  // Удалить фигуру с конечной точки если она там есть.
  boardData.value.white.on_board_chess_pieces = boardData.value.white.on_board_chess_pieces.filter((e) => {
    return e.position.x !== data.body.to.x || e.position.y !== data.body.to.y
  })
  boardData.value.black.on_board_chess_pieces = boardData.value.black.on_board_chess_pieces.filter((e) => {
    return e.position.x !== data.body.to.x || e.position.y !== data.body.to.y
  })
  let name = '';
  // Переместить фигуру на новое место.
  boardData.value.white.on_board_chess_pieces.forEach(e => {
    if (e.position.x == data.body.from.x &&
    e.position.y == data.body.from.y) {
      e.position.x = data.body.to.x
      e.position.y = data.body.to.y
      // Трансформация пешки в королеву.
      if (data.body.to.y == 8 && e.name == "pawn") {
        e.name = "queen"
      }
      name = e.name
    }
  });
  boardData.value.black.on_board_chess_pieces.forEach(e => {
    if (e.position.x == data.body.from.x &&
    e.position.y == data.body.from.y) {
      e.position.x = data.body.to.x
      e.position.y = data.body.to.y
      // Трансформация пешки в королеву.
      if (data.body.to.y == 1 && e.name == "pawn") {
        e.name = "queen"
      }
      name = e.name
    }
  });
  // Пешка пошла через клетку.
  if (name == "pawn" &&
  (data.body.from.y == 2 && data.body.to.y == 4 ||
  data.body.from.y == 7 && data.body.to.y == 5)) {
    pass = {
      x: data.body.to.x, y: data.body.to.y
    }
  } else {
    // Взятие на проходе.
    if (pass !== undefined && data.body.to.x == pass.x && ((data.body.to.y == 6 && pass.y == 5) || (data.body.to.y == 3 && pass.y == 4))) {
      // Удалить фигуру с конечной точки если она там есть.
      boardData.value.white.on_board_chess_pieces = boardData.value.white.on_board_chess_pieces.filter((e) => {
        return e.position.x !== pass.x || e.position.y !== pass.y
      })
      boardData.value.black.on_board_chess_pieces = boardData.value.black.on_board_chess_pieces.filter((e) => {
        return e.position.x !== pass.x || e.position.y !== pass.y
      })
    }
    pass = undefined
  }
}

// Обработчик событий сервера.
function EventHandler(data) {
    switch (data.name) {
    case "created":
      EventCreatedHandler()
      break
    case "clock":
      EventClockHandler(data)
      break
    case "move":
      EventMoveHandler(data)
      break
    case "status":
      state.value = data.body
      break
    case "turn":
      turn.value = data.body.name
      break
    case "offer_a_draw":
      offerDraw.value = data.body.desision_time_left
      break
    case "notice":
      DrawNotice(data.body.notice)
      break
    }
}

// Обработчик ответов сервера.
function ResponseHandler(data) {
  const {callback, timer} = callbacks[data.request_id]
  clearTimeout(timer)
  callback(data)
  delete callbacks[data.request_id]
}

// Обработчик сообщений сервера.
function MessageHandler(res) {
  const data = JSON.parse(res.data)
  if (data.request_id && callbacks[data.request_id]) {
    ResponseHandler(data)
    return
  }
  if (data.name) {
    EventHandler(data)
    return
  }
}

// Получение сообщений
ws.onmessage = (res) => {
  MessageHandler(res)
}

onMounted(() => {
  // Соединение открыто.
  ws.onopen = () => {
    GetStartInfo()
  }
})

const notice = ref('')

// Ход.
function Move(move) {
  Send({method: REQUEST_POST_MOVE, body: move}, (response) => {
    if (!response.body.valid) {
      DrawNotice(response.body.cause)
    }
  })
}

// Новая игра.
function NewGame() {
  Send({method: REQUEST_POST_NEW_GAME, body: {}}, (response) => {})
}

// Сдаться.
function Surrender() {
  if (confirm("Are you sure you want to surrender?")) {
    Send({method: REQUEST_POST_SURRENDER, body: {}}, (response) => {})
  }
}

// Предложить ничью.
function OfferADraw() {
  Send({method: REQUEST_POST_OFFER_A_DRAW, body: {}}, (response) => {
    if (!response.body.valid) {
      DrawNotice(response.body.cause)
    }
  })
}

// Принять ничью.
function AcceptDraw() {
  offerDraw.value = 0
  Send({method: REQUEST_POST_ACCEPT_DRAW, body: {}}, (response) => {})
}

// Отклонить ничью.
function RejectDraw() {
  offerDraw.value = 0
  Send({method: REQUEST_POST_REJECT_DRAW, body: {}}, (response) => {})
}

let cn
// Отрисовка нотации.
function DrawNotice(message) {
  notice.value = ''
  clearTimeout(cn)
  setTimeout(() => {
    notice.value = message
    cn = setTimeout(()=> {
      notice.value = ''
    }, NOTICE_DISPLAY)
  }, 100)
}

</script>

<template>
  <div class="grid">
    <div class="board-col">
      <ChessBoard
        @move="Move"
        :boardData="boardData"
        :team="team"
        :lastMove="lastMove"/>
    </div>
    <div class="stat-col">
      <ChessStat
        :team="team"
        :turn="turn"
        :clock="clock"
        :state="state"/>
    </div>
    <div class="actions-col">
      <ChessActions
        @new="NewGame"
        @surrender="Surrender"
        @draw="OfferADraw"
        @acceptDraw="AcceptDraw"
        @rejectDraw="RejectDraw"
        :state="state"
        :notice="notice"
        :offerDraw="offerDraw"/>
    </div>
  </div>
</template>

<style scoped>

.grid {
  display: grid;
  grid-template-columns: 50% 50%;
  grid-template-rows: auto 1fr;
  @media (max-width: 768px) {
    grid-template-columns: 100%;
  }
  /* background-color: teal; */
  .board-col {
    grid-row: 1 / 3;
    @media (max-width: 768px) {
      grid-row: 2;
    }
  }
  .stat-col {
    grid-row: 1;
    align-self: self-end;
    @media (max-width: 768px) {
      grid-row: 1;
    }
  }
  .actions-col {
    grid-row: 2;
    @media (max-width: 768px) {
      grid-row: 3;
    }
  }
}
</style>
