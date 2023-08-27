local Command = require("commander.model.Command")
local Keymap = require("commander.model.Keymap")
local constants = require("commander.constants")

local mock = require("luassert.mock")
local stub = require("luassert.stub")

describe("Command:parse()", function()
  it("correct simple item", function()
    local item = {
      desc = "test parsing a command",
      cmd = "<CMD>echo hello<CR>",
      keys = { "n", "<leader>a" },
      mode = constants.mode.ADD,
      cat = "test",
    }
    local command, err = Command:parse(item)
    assert.Nil(err)
    assert.equal(command.desc, item.desc)
    assert.equal(command.non_empty_desc, item.desc)
    assert.equal(command.cmd, item.cmd)
    assert.equal(command.cmd_str, item.cmd)
    assert.equal(#command.keymaps, 1)
    assert.equal(command.cat, item.cat)
    assert.equal(command.mode, item.mode)
  end)

  it("correct complex item", function()
    local item = {
      cmd = function()
        print("helilo")
      end,
      keys = {
        { "n",     "<leader>a" },
        { "v",     "<leader>b" },
        { { "i" }, "<leader>c" },
      },
      mode = constants.mode.ADD_SET,
      cat = "test",
    }
    local command, err = Command:parse(item)

    assert.Nil(err)
    assert.equal(command.desc, "")
    assert.equal(command.non_empty_desc, "<anonymous> lua function")
    assert.equal(command.cmd, item.cmd)
    assert.equal(command.cmd_str, "<anonymous> lua function")
    assert.equal(#command.keymaps, #item.keys)
    assert.equal(command.cat, item.cat)
    assert.equal(command.mode, item.mode)
  end)

  it("command without valid cmd", function()
    local item = {
      desc = "test parsing a command",
      keys = { "n", "<leader>a" },
      mode = constants.mode.ADD,
      cat = "test",
    }
    local _, err = Command:parse(item)
    assert.equal("cmd: expected string|function, got nil", err)

    item = {
      desc = "test parsing a command",
      keys = { "n", "<leader>a" },
      mode = constants.mode.ADD,
      cat = "test",
      cmd = 123,
    }
    _, err = Command:parse(item)
    assert.equal("cmd: expected string|function, got number", err)
  end)

  it("command without valid keymap", function()
    local item = {
      keys = {
        { "n",     "<leader>b" },
        { { "a" }, "<leader>a" },
      },
      cmd = "<CMD>echo hello<CR>",
    }
    local _, err = Command:parse(item)
    assert.equal(
      'keys[2][1]: expected vim-mode(s) (one or a list of { "n", "i", "c", "x", "v", "t" }), got { "a" }',
      err
    )

    item = {
      keys = { nil, "<leader>b" },
      cmd = "<CMD>echo hello<CR>",
    }
    _, err = Command:parse(item)
    assert.equal('keys[1]: expected vim-mode(s) (one or a list of { "n", "i", "c", "x", "v", "t" }), got nil', err)

  end)
end)

describe("Command:execute()", function()
  -- it("vim command as cmd", function()
  -- end)

  it("lua function as cmd", function()
    local cnt = 0
    local item = {
      desc = "test parsing a command",
      cmd = function()
        cnt = cnt + 1
      end,
      keys = { "n", "<leader>a" },
      mode = constants.mode.ADD,
      cat = "test",
    }
    local command, _ = Command:parse(item)
    command:execute()
    assert.equal(1, cnt)

    command:execute()
    assert.equal(2, cnt)
  end)
end)
