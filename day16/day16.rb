class Type4
  # Below each bit is a label indicating its purpose:
  #
  #   The three bits labeled V (110) are the packet version, 6.
  #   The three bits labeled T (100) are the packet type ID, 4, which means the packet is a literal value.
  #   The five bits labeled A (10111) start with a 1 (not the last group, keep reading) and contain the first four bits of the number, 0111.
  #   The five bits labeled B (11110) start with a 1 (not the last group, keep reading) and contain four more bits of the number, 1110.
  #   The five bits labeled C (00101) start with a 0 (last group, end of packet) and contain the last four bits of the number, 0101.
  # The three unlabeled 0 bits at the end are extra due to the hexadecimal representation and should be ignored.

  attr_reader :binary_string_length

  def initialize(binary_value)
    raise "wrong type #{binary_value[3..5]}" if binary_value[3..5].chars != "100".chars
    @value = binary_value

    determine_segments
  end

  def determine_segments
    @literal_binary_value =
      begin
        index = 6
        more_segments = true
        segments = ""
        while (more_segments) do
          segments += @value[(index+1)..(index+4)]
          more_segments = @value[index] == "1"
          index += 5
        end

        @binary_string_length = index
        segments
      end
  end

  def version
    @value[0..2].to_i(2)
  end

  def type_id
    4
  end

  def literal_binary_value
    @literal_binary_value
  end

  def value
    literal_binary_value.to_i(2)
  end

  def trimmed_binary_string
    @value[0...@binary_string_length]
  end

  def version_sum
    version
  end
end

class Operator
  # An operator packet contains one or more packets. To indicate which subsequent binary data represents its
  # sub-packets, an operator packet can use one of two modes indicated by the bit immediately after the
  # packet header; this is called the length type ID:

  # If the length type ID is 0, then the next 15 bits are a number that represents the total length in bits
  # of the sub-packets contained by this packet.
  # If the length type ID is 1, then the next 11 bits are a number that represents the number of sub-packets
  # immediately contained by this packet.
  def initialize(binary_value)
    @value = binary_value
  end

  def version
    @value[0..2].to_i(2)
  end

  def type_id
    @value[3..5].to_i(2)
  end

  def length_type_id
    @value[6].to_i
  end

  def length_type_length
    length_type_id == 0 ? 15 : 11
  end

  def sub_packet_length
    @value[7..21].to_i(2) if length_type_id == 0
  end

  def sub_packet_count
    @value[7..17].to_i(2) if length_type_id == 1
  end

  def sub_packets
    @sub_packets ||=
      begin
        index = 7 + length_type_length
        results = []
        while (
          (length_type_id == 0 && index < 22 + sub_packet_length) ||
          (length_type_id == 1 && results.size < sub_packet_count)
        ) do
          sub_packet = BinaryStringParser.parse(@value[index..])
          if sub_packet
            index += sub_packet.binary_string_length
            results << sub_packet
          else
            break
          end
        end
        results
      end
    end

  def version_sum
    version + sub_packets.map(&:version_sum).sum
  end

  def binary_string_length
    7 + length_type_length + sub_packets.map(&:binary_string_length).sum
  end

  def value
    # Packets with type ID 0 are sum packets - their value is the sum of the values of their sub-packets.
    # If they only have a single sub-packet, their value is the value of the sub-packet.
    if type_id == 0
      sub_packets.map(&:value).sum
    # Packets with type ID 1 are product packets - their value is the result of multiplying together the values
    # of their sub-packets. If they only have a single sub-packet, their value is the value of the sub-packet.
    elsif type_id == 1
      sub_packets.map(&:value).inject(:*)
    # Packets with type ID 2 are minimum packets - their value is the minimum of the values of their sub-packets.
    elsif type_id == 2
      sub_packets.map(&:value).min
    # Packets with type ID 3 are maximum packets - their value is the maximum of the values of their sub-packets.
    elsif type_id == 3
      sub_packets.map(&:value).max
    # Packets with type ID 5 are greater than packets - their value is 1 if the value of the first sub-packet is
    # greater than the value of the second sub-packet; otherwise, their value is 0. These packets always have exactly two sub-packets.
    elsif type_id == 5
      sub_packets[0].value > sub_packets[1].value ? 1 : 0
    # Packets with type ID 6 are less than packets - their value is 1 if the value of the first sub-packet is
    # less than the value of the second sub-packet; otherwise, their value is 0. These packets always have exactly two sub-packets.
    elsif type_id == 6
      sub_packets[0].value < sub_packets[1].value ? 1 : 0
    # Packets with type ID 7 are equal to packets - their value is 1 if the value of the first sub-packet is
    # equal to the value of the second sub-packet; otherwise, their value is 0. These packets always have exactly two sub-packets.
    elsif type_id == 7
      sub_packets[0].value == sub_packets[1].value ? 1 : 0
    else
      raise "Unknown type #{type_id}"
    end
  end
end

class HexStringParser
  def self.parse(hex_string)
    BinaryStringParser.parse(hex_to_binary(hex_string))
  end
end

class BinaryStringParser
  def self.parse(binary_string)
    type_id = binary_string[3..5]&.to_i(2)
    # puts("#{type_id} #{binary_string}")
    if type_id == 4
      Type4.new(binary_string)
    else
      Operator.new(binary_string)
    end
  end
end

def hex_to_binary(hex)
  hex.hex.to_s(2).rjust(hex.size*4, '0')
end

result = hex_to_binary("D2FE28")
raise result.inspect if result != "110100101111111000101000"

# type 4
result = BinaryStringParser.parse("110100101111111000101000")
raise if result.version != 6
raise if result.type_id != 4
raise result.literal_binary_value if result.literal_binary_value != "011111100101"
raise if result.value != 2021

# operator
result = BinaryStringParser.parse("00111000000000000110111101000101001010010001001000000000")
# The three bits labeled V (001) are the packet version, 1.
raise if result.version != 1
#   The three bits labeled T (110) are the packet type ID, 6, which means the packet is an operator.
raise if result.type_id != 6
#   The bit labeled I (0) is the length type ID, which indicates that the length is a 15-bit number representing the number of bits in the sub-packets.
raise if result.length_type_id != 0
#   The 15 bits labeled L (000000000011011) contain the length of the sub-packets in bits, 27.
raise if result.sub_packet_length != 27
#   The 11 bits labeled A contain the first sub-packet, a literal value representing the number 10.
raise if result.sub_packets[0].value != 10
#   The 16 bits labeled B contain the second sub-packet, a literal value representing the number 20.
raise if result.sub_packets[1].value != 20

# operator
result = BinaryStringParser.parse("11101110000000001101010000001100100000100011000001100000")
# The three bits labeled V (111) are the packet version, 7.
raise if result.version != 7
#   The three bits labeled T (011) are the packet type ID, 3, which means the packet is an operator.
raise if result.type_id != 3
#   The bit labeled I (1) is the length type ID, which indicates that the length is a 11-bit number representing the number of sub-packets.
raise if result.length_type_id != 1
#   The 11 bits labeled L (00000000011) contain the number of sub-packets, 3.
raise if result.sub_packet_count != 3
#   The 11 bits labeled A contain the first sub-packet, a literal value representing the number 1.
raise if result.sub_packets[0].value != 1
#   The 11 bits labeled B contain the second sub-packet, a literal value representing the number 2.
raise if result.sub_packets[1].value != 2
#   The 11 bits labeled C contain the third sub-packet, a literal value representing the number 3.
raise if result.sub_packets[2].value != 3

result = HexStringParser.parse("8A004A801A8002F478")
raise if result.version_sum != 16

result = HexStringParser.parse("620080001611562C8802118E34")
raise if result.version_sum != 12

result = HexStringParser.parse("C0015000016115A2E0802F182340")
raise result.version_sum.inspect if result.version_sum != 23

result = HexStringParser.parse("A0016C880162017C3686B18A3D4780")
raise result.version_sum.inspect if result.version_sum != 31

# C200B40A82 finds the sum of 1 and 2, resulting in the value 3.
result = HexStringParser.parse("C200B40A82")
raise if result.value != 3
# 04005AC33890 finds the product of 6 and 9, resulting in the value 54.
result = HexStringParser.parse("04005AC33890")
raise result.value.inspect if result.value != 54
# 880086C3E88112 finds the minimum of 7, 8, and 9, resulting in the value 7.
result = HexStringParser.parse("880086C3E88112")
raise if result.value != 7
# CE00C43D881120 finds the maximum of 7, 8, and 9, resulting in the value 9.
result = HexStringParser.parse("CE00C43D881120")
raise if result.value != 9
# D8005AC2A8F0 produces 1, because 5 is less than 15.
result = HexStringParser.parse("D8005AC2A8F0")
raise if result.value != 1
# F600BC2D8F produces 0, because 5 is not greater than 15.
result = HexStringParser.parse("F600BC2D8F")
raise if result.value != 0
# 9C005AC2F8F0 produces 0, because 5 is not equal to 15.
result = HexStringParser.parse("9C005AC2F8F0")
raise if result.value != 0
# 9C0141080250320F1802104A08 produces 1, because 1 + 3 = 2 * 2.
result = HexStringParser.parse("9C0141080250320F1802104A08")
raise if result.value != 1

result = HexStringParser.parse(File.read("input.txt"))
puts("step 1 - #{result.version_sum}")
puts("step 2 - #{result.value}")
