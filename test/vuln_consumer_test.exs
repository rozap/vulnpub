

defmodule Test.VulnConsumerTest do
  use ExUnit.Case
  require Service.VulnConsumer


  def raw_pacakges do
    ["3.0.0-4ubuntu1",
    "3.0.0-4ubuntu1",
    "3.0.0-4ubuntu1",
    "0.6.35-0ubuntu7",
    "2.12-1",
    "2.2.52-1",
    "0.142",
    "1:2.0.21-1ubuntu2",
    "3.113+nmu3ubuntu3",
    "1.0.25+dfsg-0ubuntu4",
    "1.0.27.2-1ubuntu2",
    "0.9.0rc2-1-9.1",
    "2.3-20ubuntu1",
    "14.04.1",
    "13.04",
    "2.8.95~2430-0ubuntu5",
    "2.14.1-0ubuntu3.2",
    "2.14.1-0ubuntu3.2",
    "0.20",
    "1.0.1ubuntu2",
    "1.3.1",
    "1.0.1ubuntu2",
    "1.0.1ubuntu2",
    "0.45ubuntu4",
    "1.1.1-1ubuntu5",
    "1.1.1-1ubuntu5",
    "1.8.1-2ubuntu1",
    "0.60.7~20110707-1ubuntu1",
    "7.1-0-1",
    "2.10.2.is.2.10.1-0ubuntu1",
    "1:2.4.47-1ubuntu1",
    "0.6.31-4ubuntu1",
    "0.6.31-4ubuntu1",
    "0.6.31-4ubuntu1",
    "7.2ubuntu5",
    "3.5.33",
    "4.3-7ubuntu1",
    "1:2.1-4",
    "1.06.95-8ubuntu1",
    "1:9.9.5.dfsg-3",
    "2.24-5ubuntu3",
    "1.23-git201403102151-1ubuntu1",
    "4.101-0ubuntu13",
    "4.101-0ubuntu13",
    "4.101-0ubuntu13",
    "3.10.0-0ubuntu1",
    "5.0-2ubuntu2",
    "5.0-2ubuntu2",
    "9.0.5ubuntu1",
    "1:2.20.1-5.1ubuntu20",
    "11.6ubuntu6",
    "1:1.21.0-1ubuntu1",
    "1:1.21.0-1ubuntu1",
    "1.0.6-5",
    "20130906ubuntu2",
    "20130815ubuntu1",
    "1.0.2-2",
    "34.0.1847.116-0ubuntu2",
    "34.0.1847.116-0ubuntu2",
    "34.0.1847.116-0ubuntu2",
    "0.7.0+r2759+trusty1~gita201307"]
  end

  def package_lists do
    [[3,0,0],
     [3,0,0],
     [3,0,0],
     [0,6,35],
     [2,12],
     [2,2,52],
     [0,142],
     [1],
     [3,113],
     [1,0,25],
     [1,0,27,2],
     [0,9,0],
     [2,3],
     [14,4,1],
     [13,4],
     [2,8,95],
     [2,14,1],
     [2,14,1],
     [0,20],
     [1,0,1],
     [1,3,1],
     [1,0,1],
     [1,0,1],
     [0,45],
     [1,1,1],
     [1,1,1],
     [1,8,1],
     [0,60,7],
     [7,1],
     [2,10,2],
     [1],
     [0,6,31],
     [0,6,31],
     [0,6,31],
     [7,2],
     [3,5,33],
     [4,3],
     [1],
     [1,6,95],
     [1],
     [2,24],
     [1,23],
     [4,101],
     [4,101],
     [4,101],
     [3,10,0],
     [5,0],
     [5,0],
     [9,0,5],
     [1],
     [11,6],
     [1],
     [1],
     [1,0,6],
     [20130906],
     [20130815],
     [1,0,2],
     [34,0,1847,116],
     [34,0,1847,116],
     [34,0,1847,116],
     [0,7,0]
    ]
  end


  test "package resolution" do
    lists = Enum.map(raw_pacakges, fn name -> Service.VulnConsumer.to_version_list name end)
    assert lists = package_lists
  end

  test "packages dont make it crash" do
    js = File.read!("test/json/packages.json")
      |> Jazz.decode!
    data = js["data"]
    lists = Enum.map(data, fn package -> Service.VulnConsumer.to_version_list package["version"] end)
  end

end
