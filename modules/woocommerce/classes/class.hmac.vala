using GLib;
using Gee;

namespace HMAC 
{
	private uchar[] sha1(uchar[] data1, uchar[]? data2 = null)	
  	{
		uchar[] ret = new uchar[20]; size_t ret_len = 20;
		var cksm = new Checksum(ChecksumType.SHA1);
		cksm.update(data1, data1.length);
		if (data2 != null) cksm.update(data2, data2.length);
		cksm.get_digest((uint8[])ret, ref ret_len);
		assert(ret_len == 20);
		return ret;
  	}
  	private uchar[] hmac_sha1(uchar[] _key, uchar[] message)
  	{
    	const int blocksize = 64;

		uchar[] key = _key;
		if (key.length > blocksize) key = sha1(key);
		while (key.length < blocksize) key += 0;
		
		uchar okey[64]; uchar ikey[64]; //<--blocksize (magic numbers because Vala doesn't accept a const int here)
		for (size_t i=0;i<blocksize;i++)
		{
		  okey[i] = 0x5c ^ key[i];
		  ikey[i] = 0x36 ^ key[i];
		}
		
		return sha1(okey, sha1(ikey, message));
	}
}
