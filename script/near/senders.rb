require 'json'

def group_senders_by_type(file_path)
  json_data = File.read(file_path)
  transactions = JSON.parse(json_data)

  groups = Hash.new { |hash, key| hash[key] = Set.new }

  transactions.each do |transaction|
    sender = transaction['sender']
    transaction['actions'].each do |action|
      type = action['type']
      groups[type].add(sender)
    end
  end

  groups.transform_values!(&:to_a).each_value(&:sort!)
  groups
end

def print_grouped_tables(groups)
  sorted_types = groups.keys.sort
  sorted_types.each do |type|
    puts "## #{type}"
    groups[type].each do |sender|
      puts "| #{sender} |"
    end
    puts
  end
end

file_path = 'data/near_transactions.json'
groups = group_senders_by_type(file_path)
print_grouped_tables(groups)

# Output:
#
### AddKey
# | 2166706d3a011d098b3bfb2f2b7f7f9e27cf5353982448b647893ea24dcb8c16 |

# ## FunctionCall
# | 01node.near |
# | 0b56937eaa0ddc22c580400c41633e8766e5891f607ae05dea4d68915eb17ca2 |
# | 6a3b825a2c3bf9bd717b841941b8c21c780382b54ddcbf84fba3eb3a8a13b563 |
# | b80b3e01232c2f13422fb76a47fe4c205ff66daede4bce8006f6759dcf517232 |
# | bemychain.near |
# | bot.pulse.near |
# | d30c3b1fc5f0190953575711d9a29ff56f7182c0afb3c9fda259cdfe9a8a4955 |
# | dio.near |
# | eb5efe8612f57b42597733f080e2c8764b3bd15dff1346d6ab954f2724facdf6 |
# | escrow.tessab.near |
# | khaled.near |
# | kimheechel883.near |
# | knyazev7aa.near |
# | lan.near |
# | mezoantropo.near |
# | mgazvoda.near |
# | monztre.near |
# | mxjxn.near |
# | navarich.near |
# | tom.zest.near |
# | yasuogankteam20gg.near |
# | zoulonggui.near |

# ## Transfer
# | 01ed558a07ef4e5543c884770d449cb87db99eda0d01c1f1aa9b6434c78edbf5 |
# | 2a96d7d063c1c16dde59ee49a6e2ee1c2342ab182f4d15619461a8c08820c12f |
# | 3f4bd270b5b2c536d8c44ebc554a5debd5d3fcc5a183d5ba9429605bfaceaa84 |
# | 425d23c3b92d96ec925f0219e9c8c8c6f691fcccb9e1648a761b29dd8e6d3cd2 |
# | 4dd22a754614fb64cd5790e621662e3b82a013071fa0b399c00424c0df7c921f |
# | 5e9b595c44891cf47e00fe2b124f919ac8c62ac3f42f76eb76c060518e6fdf8e |
# | 6396fdde3b04eff87cbb586d3949c6aa41126dd136d319b02a176c09be216ecb |
# | 65152281c25acdafb7ceab7c37c10da1ed0fcfd377eeb4281d12ba598f75bda4 |
# | 66ded729963b67fe9523c3872b8924aec21fa44def1ade255850117385a6bd4a |
# | 7747991786f445efb658b69857eadc7a57b6b475beec26ed14da8bc35bb2b5b6 |
# | 7a51197bf80a6a38d5998f5939fd9e3448b2f4285e4b876af46fba5c3a0f7018 |
# | 86e6ebcc723106eee951c344825b91a80b46f42ff8b1f4bd366f2ac72fab99d1 |
