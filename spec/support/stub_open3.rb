module StubOpen3
  def expect_output request, cli_response, parsed_response
    stdout = cli_response
    stderr = ''
    status = ''

    expect(Open3).to receive(:capture3).with(request).and_return([stdout, stderr, status])

    response = yield

    expect(response).to eq(parsed_response)
  end
end
