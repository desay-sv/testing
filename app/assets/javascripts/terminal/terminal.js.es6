window.gl = window.gl || {};

gl.Terminal = class {

  constructor(options) {
    this.options = options || {};

    options.cursorBlink = options.cursorBlink || true;
    options.screenKeys  = options.screenKeys || true;
    options.cols = options.cols || 100;
    options.rows = options.rows || 40;
    this.container = document.querySelector(options.selector);

    this.setSocketUrl();
    this.createTerminal();
  }

  setSocketUrl() {
    const {protocol, hostname, port} = window.location;
    const wsProtocol = protocol === 'https:' ? 'wss://' : 'ws://';

    this.socketUrl = `${wsProtocol}${hostname}:${port}/gitlab-org/gitlab-ce/deployments/4/terminal_websocket`
  }

  createTerminal() {
    this.terminal = new Terminal(this.options);
    this.socket = new WebSocket(this.socketUrl);

    this.terminal.open(this.container);
    this.terminal.fit();

    this.socket.onopen = () => { this.runTerminal() };
    this.socket.onclose = () => { this.handleSocketFailure() };
    this.socket.onerror = () => { this.handleSocketFailure() };
  }

  runTerminal() {
    const {cols, rows} = this.terminal.proposeGeometry();
    const {offsetWidth, offsetHeight} = this.terminal.element;

    this.charWidth = Math.ceil(offsetWidth / cols);
    this.charHeight = Math.ceil(offsetHeight / rows);

    this.terminal.attach(this.socket);
    this.isTerminalInitialized = true;
    this.setTerminalSize(cols, rows);
  }

  setTerminalSize (cols, rows) {
    const width = `${(cols * this.charWidth).toString()}px`;
    const height = `${(rows * this.charHeight).toString()}px`;

    this.container.style.width = width;
    this.container.style.height = height;
    this.terminal.resize(cols, rows);
  }

  handleSocketFailure() {
    console.error('There is a problem with Terminal connection. Please try again!');
  }

}