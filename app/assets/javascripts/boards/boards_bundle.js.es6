/* eslint-disable */

function require_all(context) { return context.keys().map(context); }

window.Vue = require('vue');
window.Vue.use(require('vue-resource'));
window.Sortable = require('vendor/Sortable');
require_all(require.context('./models',   true, /^\.\/.*\.(js|es6)$/));
require_all(require.context('./stores',   true, /^\.\/.*\.(js|es6)$/));
require_all(require.context('./services', true, /^\.\/.*\.(js|es6)$/));
require_all(require.context('./mixins',   true, /^\.\/.*\.(js|es6)$/));
require_all(require.context('./filters',  true, /^\.\/.*\.(js|es6)$/));
require('./components/board');
require('./components/board_sidebar');
require('./components/new_list_dropdown');
require('./vue_resource_interceptor');

$(() => {
  const $boardApp = document.getElementById('board-app'),
        Store = gl.issueBoards.BoardsStore;

  window.gl = window.gl || {};

  if (gl.IssueBoardsApp) {
    gl.IssueBoardsApp.$destroy(true);
  }

  Store.create();

  gl.IssueBoardsApp = new Vue({
    el: $boardApp,
    components: {
      'board': gl.issueBoards.Board,
      'board-sidebar': gl.issueBoards.BoardSidebar
    },
    data: {
      state: Store.state,
      loading: true,
      endpoint: $boardApp.dataset.endpoint,
      boardId: $boardApp.dataset.boardId,
      disabled: $boardApp.dataset.disabled === 'true',
      issueLinkBase: $boardApp.dataset.issueLinkBase,
      detailIssue: Store.detail
    },
    computed: {
      detailIssueVisible () {
        return Object.keys(this.detailIssue.issue).length;
      },
    },
    created () {
      gl.boardService = new BoardService(this.endpoint, this.boardId);
    },
    mounted () {
      Store.disabled = this.disabled;
      gl.boardService.all()
        .then((resp) => {
          resp.json().forEach((board) => {
            const list = Store.addList(board);

            if (list.type === 'done') {
              list.position = Infinity;
            } else if (list.type === 'backlog') {
              list.position = -1;
            }
          });

          this.state.lists = _.sortBy(this.state.lists, 'position');

          Store.addBlankState();
          this.loading = false;
        });
    }
  });

  gl.IssueBoardsSearch = new Vue({
    el: '#js-boards-seach',
    data: {
      filters: Store.state.filters
    },
    mounted () {
      gl.issueBoards.newListDropdownInit();
    }
  });
});
