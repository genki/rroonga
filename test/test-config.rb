# Copyright (C) 2015-2016  Kouhei Sutou <kou@clear-code.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License version 2.1 as published by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

class ConfigTest < Test::Unit::TestCase
  include GroongaTestUtils

  setup :setup_database

  sub_test_case "#[]" do
    test "existent" do
      context.config["rroonga.key"] = "value"
      assert_equal("value", context.config["rroonga.key"])
    end

    test "nonexistent" do
      assert_nil(context.config["nonexistent"])
    end
  end
end
