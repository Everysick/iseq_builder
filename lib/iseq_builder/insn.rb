module ISeqBuilder
  class Insn
    attr_reader :opcode, :operand

    def initialize(sequence, opcode, *operand)
      @sequence = sequence
      @opcode = opcode
      @operand = operand
      @pc = @sequence.pc
    end

    def size
      1 + operand.size
    end

    def to_bin
      [INSN_TYPE.index(opcode), operand_real_val].flatten.pack("q*")
    end

    def operand_real_val
      operand = @operand.dup
      case opcode
      when :setlocal_OP__WC__0, :getlocal_OP__WC__0
        operand[0] = @sequence.local_table.size - operand[0] + VM_ENV_DATA_SIZE
      when :opt_send_without_block, :opt_plus, :opt_minus, :opt_eq, :opt_mod, :opt_aref, :opt_aset
        operand[0] = 0
      when :getinlinecache, :setinlinecache, :jump, :branchunless
        operand[0] = @sequence.label_table[operand[0]] - (@pc + size)
      end
      operand.map!(&self.method(:operand_to_i))
      operand
    end

    def operand_to_i(operand)
      case operand
      when ISeqBuilder::ISeqObject
        operand.id
      when ISeqBuilder::CallInfo
        operand.id
      else
        operand
      end
    end

    def inspect
      "#{@opcode}\t#{@operand.map(&:to_s).join("\t")}"
    end
  end
end
