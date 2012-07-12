(function() {
  var Client, Moon, Player, Scene, Sprite, clock, publicUrl;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; }, __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
  window.Chat = (function() {
    function Chat() {
      this.keyDown = __bind(this.keyDown, this);      this.input = document.getElementById('chat');
      this.input.addEventListener('keydown', this.keyDown, false);
    }
    Chat.prototype.showWindow = function() {
      this.input.value = '';
      this.input.style.display = 'block';
      return this.input.focus();
    };
    Chat.prototype.hideWindow = function() {
      this.input.blur();
      return this.input.style.display = 'none';
    };
    Chat.prototype.sendMessage = function() {
      return client.sendMessage(this.input.value);
    };
    Chat.prototype.receiveMessage = function(data) {
      var callback, date, li;
      callback = function() {
        return game.players[data.id].displayMessage(data.message);
      };
      callback();
      date = new Date();
      li = document.createElement('li');
      li.innerText = li.textContent = "" + (date.getHours()) + ":" + (date.getMinutes()) + ":" + (date.getSeconds()) + " - " + data.message;
      li.addEventListener('click', callback, false);
      document.getElementById('chat-log').appendChild(li);
      return li.scrollIntoView();
    };
    Chat.prototype.keyDown = function(e) {
      e.stopPropagation();
      if (e.keyCode === Key.KEYS.enter) {
        this.sendMessage();
        return this.hideWindow();
      } else if (e.keyCode === Key.KEYS.escape) {
        return this.hideWindow();
      }
    };
    return Chat;
  })();
  Client = (function() {
    var now;
    now = window.now;
    function Client(game) {
      this.game = game;
      now.addPlayers = __bind(function(players) {
        var id, player, _results;
        _results = [];
        for (id in players) {
          player = players[id];
          this.game.addPlayer(id, player.position, this.id() === id, player.items);
          console.log("CREATING " + id);
          _results.push(console.log("I AM " + (this.id())));
        }
        return _results;
      }, this);
      now.removePlayer = __bind(function(id) {
        var player;
        player = this.game.players[id];
        if (player) {
          game.scene.remove(player);
          this.game.players[id] = null;
          return delete this.game.players[id];
        }
      }, this);
      now.updateInventory = __bind(function(data) {
        var player;
        player = this.game.players[data.id];
        if (data.equipped) {
          return player.equipItem(data.item);
        } else {
          return player.unequipItem(data.item);
        }
      }, this);
      now.updatePlayer = __bind(function(data) {
        var player;
        if (data.id === this.id()) {
          return;
        }
        if (player = this.game.players[data.id]) {
          player.position.x = data.position.x;
          player.position.y = data.position.y;
          player.position.z = data.position.z;
          return player.voicePitch = data.voicePitch;
        }
      }, this);
      now.receiveMessage = __bind(function(data) {
        return chat.receiveMessage(data);
      }, this);
      setInterval(this.sendUpdate, 33);
    }
    Client.prototype.id = function() {
      return now.core.clientId;
    };
    Client.prototype.sendUpdate = function() {
      var player;
      player = this.game.player;
      if (!player) {
        return;
      }
      return now.sendUpdate({
        position: player.position,
        voicePitch: player.voicePitch,
        items: Object.keys(game.player.items)
      });
    };
    Client.prototype.sendMessage = function(message) {
      return now.sendMessage(message);
    };
    Client.prototype.sendEquipUpdate = function(item, equipped) {
      return now.sendEquipUpdate(item, equipped);
    };
    return Client;
  })();
  window.Inventory = (function() {
    function Inventory() {
      this.keyDown = __bind(this.keyDown, this);
      var _this;
      this.elem = $("#inventory");
      $("body").keydown(this.keyDown);
      _this = this;
      $('#inventory li').click(function(e) {
        var item;
        item = $(this).find("img").data("item");
        return _this.toggleItem(item);
      });
    }
    Inventory.prototype.toggle = function() {
      return this.elem.toggle();
    };
    Inventory.prototype.toggleItem = function(item) {
      if (!game.player.items[item]) {
        return client.sendEquipUpdate(item, true);
      } else {
        return client.sendEquipUpdate(item, false);
      }
    };
    Inventory.prototype.keyDown = function(e) {
      if (e.keyCode === 73) {
        return this.toggle();
      }
    };
    return Inventory;
  })();
  clock = new THREE.Clock();
  publicUrl = "/public/";
  window.Key = (function() {
    Key.KEYS = {
      'up': 38,
      'down': 40,
      'left': 37,
      'right': 39,
      'space': 32,
      'enter': 13,
      'escape': 27
    };
    function Key(node, map) {
      this.map = map;
      this.onKeyUp = __bind(this.onKeyUp, this);
      this.onKeyDown = __bind(this.onKeyDown, this);
      this.pressed = [];
      node.addEventListener('keydown', this.onKeyDown, false);
      node.addEventListener('keyup', this.onKeyUp, false);
    }
    Key.prototype.update = function(callContext) {
      var func, keyCode, name, _ref, _results;
      _ref = this.map;
      _results = [];
      for (name in _ref) {
        func = _ref[name];
        keyCode = Key.KEYS[name];
        _results.push(this.isDown(keyCode) ? func.call(callContext) : void 0);
      }
      return _results;
    };
    Key.prototype.isDown = function(keyCode) {
      return this.pressed[keyCode];
    };
    Key.prototype.onKeyDown = function(event) {
      if (window.debugKeyCodes) {
        console.log(event.keyCode);
      }
      return this.pressed[event.keyCode] = true;
    };
    Key.prototype.onKeyUp = function(event) {
      if (!this.handlingKeys) {
        return this.pressed[event.keyCode] = false;
      }
    };
    return Key;
  })();
  Scene = (function() {
    Scene.prototype.createRenderer = function() {
      this.container = document.createElement('div');
      document.body.appendChild(this.container);
      this.renderer = new THREE.WebGLRenderer({
        antialias: true
      });
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      this.container.appendChild(this.renderer.domElement);
      if (typeof Stats !== "undefined" && Stats !== null) {
        this.stats = new Stats();
        this.stats.domElement.style.position = 'absolute';
        this.stats.domElement.style.top = '0px';
        this.container.appendChild(this.stats.domElement);
      }
      return window.addEventListener('resize', __bind(function() {
        this.camera.aspect = window.innerWidth / window.innerHeight;
        this.renderer.setSize(window.innerWidth, window.innerHeight);
        return this.camera.updateProjectionMatrix();
      }, this));
    };
    function Scene() {
      this.render = __bind(this.render, this);
      var aspect, far, flareColor, fov, geometry, material, near, skyMaterial, skyShader, skyTexture, textureFlare0, textureFlare2, textureFlare3, urls;
      this.handler = new Key(window, {
        'up': function() {
          return this.player.forward(1);
        },
        'down': function() {
          return this.player.forward(-1);
        },
        'left': function() {
          return this.player.turn(1);
        },
        'right': function() {
          return this.player.turn(-1);
        },
        'space': function() {
          return this.player.jump(1);
        },
        'enter': function() {
          return chat.showWindow();
        }
      });
      this.scene = new THREE.Scene;
      fov = 50;
      aspect = window.innerWidth / window.innerHeight;
      near = 1;
      far = 100000;
      this.camera = new THREE.PerspectiveCamera(fov, aspect, near, far);
      this.scene.add(this.camera);
      this.players = {};
      this.moon = new Moon();
      this.add(this.moon);
      urls = ["" + publicUrl + "/posx.png", "" + publicUrl + "/negx.png", "" + publicUrl + "/posy.png", "" + publicUrl + "/negy.png", "" + publicUrl + "/posz.png", "" + publicUrl + "/negz.png"];
      skyTexture = THREE.ImageUtils.loadTextureCube(urls);
      skyShader = THREE.ShaderUtils.lib["cube"];
      skyShader.uniforms["tCube"].texture = skyTexture;
      skyMaterial = new THREE.ShaderMaterial({
        uniforms: skyShader.uniforms,
        vertexShader: skyShader.vertexShader,
        fragmentShader: skyShader.fragmentShader,
        depthWrite: false
      });
      this.skybox = new THREE.Mesh(new THREE.CubeGeometry(10000, 10000, 10000, 1, 1, 1, null, true), skyMaterial);
      this.skybox.flipSided = true;
      this.add(this.skybox);
      geometry = new THREE.PlaneGeometry(256, 256, 1, 1);
      material = new THREE.MeshPhongMaterial({
        ambient: 0xffffff,
        diffuse: 0xffffff,
        specular: 0xff9900,
        shininess: 64
      });
      this.milk = new THREE.Mesh(geometry, material);
      this.milk.doubleSided = true;
      this.milk.position.y = 5;
      this.add(this.milk);
      geometry = new THREE.CubeGeometry(3, 5, 3);
      material = new THREE.MeshBasicMaterial({
        map: THREE.ImageUtils.loadTexture("/public/tardisFront.jpg")
      });
      this.tardis = new THREE.Mesh(geometry, material);
      this.tardis.position = new THREE.Vector3(-20, 10.5, -60);
      this.add(this.tardis);
      this.earth = new THREE.Mesh(new THREE.SphereGeometry(50, 20, 20), new THREE.MeshLambertMaterial({
        map: THREE.ImageUtils.loadTexture("/public/earth.jpg"),
        color: 0xeeeeee
      }));
      this.earth.position.z = 500;
      this.earth.position.y = 79;
      this.earth.rotation.y = 2.54;
      this.add(this.earth);
      textureFlare0 = THREE.ImageUtils.loadTexture("/public/lensflare0.png");
      textureFlare2 = THREE.ImageUtils.loadTexture("/public/lensflare2.png");
      textureFlare3 = THREE.ImageUtils.loadTexture("/public/lensflare3.png");
      flareColor = new THREE.Color(0xffffff);
      THREE.ColorUtils.adjustHSV(flareColor, 0, -0.5, 0.5);
      this.sun = new THREE.LensFlare(textureFlare0, 700, 0.0, THREE.AdditiveBlending, flareColor);
      this.sun.add(textureFlare2, 512, 0.0, THREE.AdditiveBlending);
      this.sun.add(textureFlare2, 512, 0.0, THREE.AdditiveBlending);
      this.sun.add(textureFlare2, 512, 0.0, THREE.AdditiveBlending);
      this.sun.add(textureFlare3, 60, 0.6, THREE.AdditiveBlending);
      this.sun.add(textureFlare3, 70, 0.7, THREE.AdditiveBlending);
      this.sun.add(textureFlare3, 120, 0.9, THREE.AdditiveBlending);
      this.sun.add(textureFlare3, 70, 1.0, THREE.AdditiveBlending);
      this.sun.position.x = 0;
      this.sun.position.y = 30;
      this.sun.position.z = -500;
      this.scene.add(this.sun);
      this.pointLight = new THREE.PointLight(0x666666);
      this.sunlight = new THREE.DirectionalLight();
      this.sunlight.position.set(0, 50, -100).normalize();
      this.ambient = new THREE.AmbientLight(0x222222);
      this.scene.add(this.sunlight);
      this.add(this.ambient);
      this.add(this.pointLight);
      this.scene.fog = new THREE.Fog(0x0, 1, 10000);
      this.createRenderer();
    }
    Scene.prototype.add = function(object) {
      return this.scene.add(object);
    };
    Scene.prototype.remove = function(object) {
      return this.scene.remove(object);
    };
    Scene.prototype.addPlayer = function(id, position, currentPlayer, items) {
      var p;
      if (position == null) {
        position = new THREE.Vector3(7, 12, -70);
      }
      if (currentPlayer == null) {
        currentPlayer = false;
      }
      p = new Player(position, items);
      this.players[id] = p;
      this.add(p);
      if (currentPlayer) {
        this.player = p;
        return requestAnimationFrame(this.render, this.renderer.domElement);
      }
    };
    Scene.prototype.render = function(time) {
      var delta, mapHeightAtCamera, mapHeightAtPlayer, player, target, timestep, _, _ref;
      if (!this.player) {
        return;
      }
      delta = clock.getDelta();
      requestAnimationFrame(this.render, this.renderer.domElement);
      timestep = (time - this.lastFrameTime) * 0.001;
      this.stats.update();
      this.handler.update(this);
      this.player.update(delta);
      mapHeightAtPlayer = this.moon.getHeight(this.player.position.x, this.player.position.z);
      if (mapHeightAtPlayer > this.player.position.y - 0.8) {
        this.player.position.y = mapHeightAtPlayer + 0.8;
        this.player.jumping = false;
      }
      target = this.player.position.clone().subSelf(this.player.direction().multiplyScalar(-8));
      this.camera.position = this.camera.position.addSelf(target.subSelf(this.camera.position).multiplyScalar(0.1));
      mapHeightAtCamera = this.moon.getHeight(this.camera.position.x, this.camera.position.z);
      if (mapHeightAtCamera > (this.player.position.y - 2)) {
        this.camera.position.y = mapHeightAtCamera + 2;
        this.player.jumping = false;
      }
      this.camera.lookAt(this.player.position);
      this.pointLight.position = this.player.position.clone();
      this.pointLight.position.y += 10;
      if (this.player.position.y < (this.milk.position.y - 3)) {
        this.scene.fog.far = 20;
      } else {
        this.scene.fog.far = 100000;
      }
      _ref = this.players;
      for (_ in _ref) {
        player = _ref[_];
        player.updateChildren(_);
      }
      this.earth.rotation.y += 0.01;
      this.earth.rotation.z += 0.005;
      this.earth.rotation.x += 0.005;
      return this.renderer.render(this.scene, this.camera);
    };
    return Scene;
  })();
  $(document).ready(function() {
    var client, game;
    game = new Scene;
    client = new Client(game);
    window.chat = new Chat;
    window.inventory = new Inventory;
    window.game = game;
    return window.client = client;
  });
  Moon = (function() {
    __extends(Moon, THREE.Object3D);
    function Moon() {
      var img;
      Moon.__super__.constructor.call(this);
      img = new Image();
      img.onload = __bind(function() {
        var planeTex, vertex, _i, _len, _ref;
        this.height = img.height;
        this.width = img.width;
        this.numRows = this.height - 1;
        this.numCols = this.width - 1;
        this.cellWidth = (this.numRows + 1) / this.height;
        this.cellHeight = (this.numCols + 1) / this.width;
        this.geometry = new THREE.PlaneGeometry(this.width, this.height, this.numRows, this.numCols);
        this.geometry.dynamic = true;
        this.heights = this.getHeightData(img);
        _ref = this.geometry.vertices;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          vertex = _ref[_i];
          vertex.y = this.heights[_i];
        }
        this.geometry.computeFaceNormals();
        planeTex = THREE.ImageUtils.loadTexture("public/dirt.jpg");
        planeTex.wrapS = planeTex.wrapT = THREE.RepeatWrapping;
        planeTex.repeat.set(10, 10);
        this.material = new THREE.MeshLambertMaterial({
          map: planeTex,
          shading: THREE.SmoothShading,
          specular: 0x0,
          ambient: 0xeeeeee,
          diffuse: 0x0,
          color: 0x555555,
          shininess: 32
        });
        this.mesh = new THREE.Mesh(this.geometry, this.material);
        return this.add(this.mesh);
      }, this);
      img.src = 'public/map.jpg';
    }
    Moon.prototype.getHeight = function(x, z) {
      var col0, col1, gridX, gridZ, h00, h01, h10, h11, height, row0, row1, tx, txty, ty;
      if (!this.heights) {
        return 0;
      }
      x += this.numCols * this.cellWidth * 0.5;
      z += this.numRows * this.cellHeight * 0.5;
      gridX = x / this.cellWidth;
      gridZ = z / this.cellHeight;
      col0 = Math.floor(gridX);
      row0 = Math.floor(gridZ);
      col1 = col0 + 1;
      row1 = row0 + 1;
      if (col1 > this.numCols) {
        col1 = 0;
      }
      if (row1 > this.numRows) {
        row1 = 0;
      }
      h00 = this.heights[col0 + row0 * (this.numCols + 1)];
      h01 = this.heights[col1 + row0 * (this.numCols + 1)];
      h11 = this.heights[col1 + row1 * (this.numCols + 1)];
      h10 = this.heights[col0 + row1 * (this.numCols + 1)];
      tx = gridX - col0;
      ty = gridZ - row0;
      txty = tx * ty;
      height = h00 * (1 - ty - tx + txty) + h01 * (tx - txty) + h11 * txty + h10 * (ty - txty);
      return height;
    };
    Moon.prototype.getHeightData = function(img) {
      var all, canvas, context, data, i, imgd, j, pic, pix, size, _len, _step;
      canvas = document.createElement('canvas');
      canvas.width = img.width;
      canvas.height = img.height;
      context = canvas.getContext('2d');
      size = img.width * img.height;
      data = new Float32Array(size);
      context.drawImage(img, 0, 0);
      imgd = context.getImageData(0, 0, img.width, img.height);
      pix = imgd.data;
      j = 0;
      for (i = 0, _len = pix.length, _step = 4; i < _len; i += _step) {
        pic = pix[i];
        all = pic + pix[i + 1] + pix[i + 2];
        data[j++] = all / 30;
      }
      return data;
    };
    return Moon;
  })();
  Player = (function() {
    var ITEM_OFFSETS, ITEM_OPTIONS, TEXT_OPTIONS;
    __extends(Player, THREE.Object3D);
    ITEM_OPTIONS = {
      dino: 'mask',
      helmet: 'mask',
      hat: 'hat',
      milk: 'hand',
      cookies: 'hand'
    };
    ITEM_OFFSETS = {
      mask: {
        x: 0,
        y: 0.6
      },
      hand: {
        x: 0.45,
        y: 0
      },
      hat: {
        x: 0,
        y: 0.9
      }
    };
    function Player(position, startingItems) {
      var item, _i, _len;
      if (startingItems == null) {
        startingItems = [];
      }
      this.clearMessage = __bind(this.clearMessage, this);
      Player.__super__.constructor.call(this);
      this.position = position;
      this.velocity = 0;
      this.yVelocity = 0;
      this.speed = 0.05;
      this.maxSpeed = 0.2;
      this.angularVelocity = 0;
      this.turnSpeed = 0.01;
      this.maxTurnSpeed = 0.02;
      this.useQuaternion = true;
      this.jumping = false;
      this.scaleFactor = 0.0001;
      this.items = {};
      this.sprite = new Sprite("robot.png");
      this.add(this.sprite);
      this.voicePitch = Math.random() * 100;
      for (_i = 0, _len = startingItems.length; _i < _len; _i++) {
        item = startingItems[_i];
        this.equipItem(item);
      }
    }
    Player.prototype.direction = function() {
      var c_orient_axis;
      c_orient_axis = new THREE.Vector3();
      this.quaternion.multiplyVector3(new THREE.Vector3(0, 0, 1), c_orient_axis);
      return c_orient_axis;
    };
    Player.prototype.forward = function(direction) {
      this.velocity += this.speed * direction;
      if (this.velocity > this.maxSpeed) {
        return this.velocity = this.maxSpeed;
      } else if (this.velocity < -this.maxSpeed) {
        return this.velocity = -this.maxSpeed;
      }
    };
    Player.prototype.jump = function(direction) {
      if (!this.jumping) {
        this.yVelocity = this.speed;
        return this.jumping = true;
      }
    };
    Player.prototype.turn = function(direction) {
      this.angularVelocity += this.turnSpeed * direction;
      if (this.angularVelocity > this.maxTurnSpeed) {
        return this.angularVelocity = this.maxTurnSpeed;
      } else if (this.angularVelocity < -this.maxTurnSpeed) {
        return this.angularVelocity = -this.maxTurnSpeed;
      }
    };
    Player.prototype.equipItem = function(item) {
      var itemSprite, offset, slot;
      if (!this.items[item]) {
        itemSprite = new Sprite("" + item + ".png");
        slot = ITEM_OPTIONS[item] || "hand";
        offset = ITEM_OFFSETS[slot];
        itemSprite.position.set(offset.x, offset.y, 0.1);
        this.add(itemSprite);
        return this.items[item] = itemSprite;
      }
    };
    Player.prototype.unequipItem = function(item) {
      if (this.items[item]) {
        this.remove(this.items[item]);
        this.items[item] = null;
        return delete this.items[item];
      }
    };
    Player.prototype.update = function(timestep) {
      var rotation;
      rotation = new THREE.Quaternion();
      rotation.setFromAxisAngle(new THREE.Vector3(0, 1, 0), this.angularVelocity);
      this.quaternion.multiplySelf(rotation);
      this.angularVelocity *= 0.9;
      this.velocity *= 0.8;
      this.position.subSelf(this.direction().multiplyScalar(this.velocity));
      this.position.y += this.yVelocity;
      return this.yVelocity -= 0.0005;
    };
    Player.prototype.updateChildren = function() {
      var mesh;
      if (mesh = this.textMesh) {
        mesh.position.x = this.position.x;
        mesh.position.y = this.position.y + 1.1;
        mesh.position.z = this.position.z;
        mesh.lookAt(game.camera.position);
        return mesh.translateX(-mesh.width);
      }
    };
    TEXT_OPTIONS = {
      size: 32,
      height: 6,
      curveSegments: 4,
      font: "helvetiker",
      weight: "normal",
      style: "normal",
      bevelEnabled: true,
      bevelThickness: 0.25,
      bevelSize: 0.25,
      bend: false,
      material: 0,
      extrudeMaterial: 1
    };
    Player.prototype.displayMessage = function(message) {
      var faceMaterial, frontMaterial, geo, mesh, sideMaterial;
      if (this.textMesh) {
        this.clearMessage();
      }
      speak.play(message, {
        pitch: this.voicePitch
      }, this.clearMessage);
      faceMaterial = new THREE.MeshFaceMaterial;
      frontMaterial = new THREE.MeshBasicMaterial({
        color: 0xffffff,
        shading: THREE.FlatShading
      });
      sideMaterial = new THREE.MeshBasicMaterial({
        color: 0xbbbbbb,
        shading: THREE.SmoothShading
      });
      geo = new THREE.TextGeometry(message, TEXT_OPTIONS);
      geo.materials = [frontMaterial, sideMaterial];
      geo.computeBoundingBox();
      geo.computeVertexNormals();
      this.textMesh = mesh = new THREE.Mesh(geo, faceMaterial);
      mesh.scale.x = mesh.scale.y = mesh.scale.z = 0.01;
      mesh.width = geo.boundingBox.max.x * mesh.scale.x / 2;
      return game.add(mesh);
    };
    Player.prototype.clearMessage = function() {
      return game.remove(this.textMesh);
    };
    return Player;
  })();
  Sprite = (function() {
    var SCALE_FACTOR;
    __extends(Sprite, THREE.Object3D);
    SCALE_FACTOR = 0.0001;
    function Sprite(fileName) {
      Sprite.__super__.constructor.call(this);
      this.texture = THREE.ImageUtils.loadTexture("/public/" + fileName, null, __bind(function() {
        this.mesh = new THREE.Sprite({
          map: this.texture,
          size: SCALE_FACTOR,
          useScreenCoordinates: false,
          color: 0xffffff
        });
        this.mesh.scale.x = this.texture.image.width * SCALE_FACTOR;
        this.mesh.scale.y = this.texture.image.height * SCALE_FACTOR;
        return this.add(this.mesh);
      }, this));
    }
    return Sprite;
  })();
}).call(this);
